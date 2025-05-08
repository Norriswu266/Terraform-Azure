terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
 alias           = "tenant_mftest"
 subscription_id = "5d3db4b8-2e8e-4706-8e0c-c0aabaf83efc"
 tenant_id       = "f49dc4c8-5df8-44db-8c6e-5055502fed2a"
 features        {}
}

module "tenant_mftest" {
  source = "../../windows_vm"
  providers = {
    azurerm = azurerm.tenant_mftest
  }
  location            = "East Asia"
  resource_group_name = "tenant-mftest-rg"
}

output "public_ip" {
  value = module.tenant_mftest.public_ip
}

output "private_ip" {
  value = module.tenant_mftest.private_ip
}


