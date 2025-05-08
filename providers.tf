# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  alias = "tenant_mftest"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "tenant_mftest" {
  source = "./modules/tenant"

  providers = {
    azurerm = azurerm.tenant_mftest
  }
}
