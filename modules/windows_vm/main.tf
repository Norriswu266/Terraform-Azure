resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[var.subnet_names[0]].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.this.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myosdisk1"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  provision_vm_agent = true
}

resource "azurerm_virtual_machine_extension" "iis_setup" {
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"Install-WindowsFeature -name Web-Server -IncludeManagementTools\""
    }
SETTINGS
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
    name                       = "AllowRDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}



resource "azurerm_virtual_network" "this" {
  ## 這是資源群組的名稱，動態生成 ex: my-vm-vnet
  name                = "${var.vm_name}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "subnets" {
  for_each             = { for idx, name in var.subnet_names : name => var.subnet_prefixes[idx] }
  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}


resource "azurerm_public_ip" "this" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "public_ip" {
  value = azurerm_public_ip.this.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}