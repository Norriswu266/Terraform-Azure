
resource "azurerm_resource_group" "this" {
  name     = "ST-SAPDR"
  location = var.location
}

module "windows_vm" {
  source              = "./modules/windows_vm"
  count               = var.os_type == "windows" ? 1 : 0
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

module "linux_vm" {
  source              = "./modules/linux_vm"
  count               = var.os_type == "linux" ? 1 : 0
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

# terraform {
#   backend "azurerm" {
#     resource_group_name   = "tfstate-rg"
#     storage_account_name  = "tfstateblobnorris "
#     container_name        = "tfstatedemonorris"
#     key                   = "${terraform.workspace}.tfstate"
#   }
# }

# module "vpn" {
#   source              = "./modules/vpn"
#   count               = var.enable_vpn ? 1 : 0
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   public_ip_id        = var.azurerm_public_ip.id
#   gateway_subnet_id   = azurerm_subnet_gateway_subnet.id
# }

output "windows_vm_public_ip" {
  value = length(module.windows_vm) > 0 ? module.windows_vm[0].public_ip : null
}

output "windows_vm_private_ip" {
  value = length(module.windows_vm) > 0 ? module.windows_vm[0].private_ip : null
}

# output "iis_url" {
#   value = length(module.windows_vm) > 0 ? "http://${module.windows_vm[0].public_ip}" : null

# }

output "linux_vm_public_ip" {
  value = length(module.linux_vm) > 0 ? module.linux_vm[0].public_ip : null
}

output "linux_vm_private_ip" {
  value = length(module.linux_vm) > 0 ? module.linux_vm[0].private_ip : null
}


