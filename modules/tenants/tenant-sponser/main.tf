terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
 alias           = "tenant_sponser"
 subscription_id = "1916de98-8f9e-4ca9-a034-a4de94446e44"
 tenant_id       = "b7238b2a-492c-4b29-86c1-249d355a9025"
 features        {}
}

module "tenant_sponser" {
  source = "../../windows_vm"
  providers = {
    azurerm = azurerm.tenant_sponser
  }
  location            = "East Asia"
  resource_group_name = "norris-rg-terraform"
}

output "public_ip" {
  value = module.tenant_sponser.public_ip
}

output "private_ip" {
  value = module.tenant_sponser.private_ip
}


