

# 登入方式
# az keyvault secret show --vault-name norris-kv --name ssh-private-key --query value -o tsv > id_rsa
# chmod 600 id_rsa
# ssh -i id_rsa norris@23.102.235.171

# 執行完第一次 terraform apply 後，建議馬上執行以下指令清理敏感資訊
# terraform state rm "module.linux_vm[0].tls_private_key.ssh_key"
# terraform state rm "module.linux_vm[0].azurerm_key_vault_secret.ssh_private_key"
# terraform state rm "module.linux_vm[0].azurerm_key_vault_secret.ssh_public_key"

## terraform destroy 

# 獲取目前登入用戶資訊
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_key_vault" "norris-kv" {
  name                       = "norris-kv"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

# Key Vault 存取權限設定
resource "azurerm_key_vault_access_policy" "norris-kv-policy" {
  key_vault_id = azurerm_key_vault.norris-kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions         = ["Get", "List"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Backup", "Restore"]
  storage_permissions     = []
  certificate_permissions = []
}


# 1. 產生 SSH 金鑰對（不寫入本機磁碟，而是存在 Terraform 狀態中）
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. 建立 Azure Key Vault 中的 SSH 公鑰祕密
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-public-key"
  value        = tls_private_key.ssh_key.public_key_openssh
  key_vault_id = azurerm_key_vault.norris-kv.id
  depends_on   = [azurerm_key_vault_access_policy.norris-kv-policy]
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = tls_private_key.ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.norris-kv.id
  depends_on   = [azurerm_key_vault_access_policy.norris-kv-policy]
}


resource "azurerm_virtual_network" "this" {
  ## 這是資源群組的名稱，動態生成 ex: my-vm-vnet
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}


resource "azurerm_subnet" "this" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  #count                = var.windows_vm_count
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myosdisk1"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  disable_password_authentication = true
  depends_on                      = [azurerm_key_vault_secret.ssh_public_key]

}


resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
resource "azurerm_network_security_group" "this" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_public_ip" "this" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = azurerm_public_ip.this.ip_address
}
output "private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}
