terraform {
  required_version = "~> 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "dbc845a4-0138-405d-aaa8-702fc8f0075e"
  tenant_id       = "0a17712b-6df3-425d-808e-309df28a5eeb"
}