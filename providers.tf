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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  tenant_id       = "d818c843-689e-4609-bb79-276ef9a67b5e"
  subscription_id = "fb7a3f8c-8367-4ca9-9395-04b190543c1d"
  # tenant_id       = "f1227eab-e2cf-4c66-a910-b8c3b5db34a8"
  # subscription_id = "894b3de8-c74a-4759-9639-ebaae15d2a48"
}