terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
 alias           = "tenant_norris"
 subscription_id = "894b3de8-c74a-4759-9639-ebaae15d2a48"
 tenant_id       = "f1227eab-e2cf-4c66-a910-b8c3b5db34a8"
 features        {}
}

module "tenant_norris" {
  source = "../../windows_vm"
  providers = {
    azurerm = azurerm.tenant_norris
  }
  location            = "East Asia"
  resource_group_name = "tenant-norris-rg"
}

output "public_ip" {
  value = module.tenant_norris.public_ip
}

output "private_ip" {
  value = module.tenant_norris.private_ip
}


