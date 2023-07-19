terraform {
  required_version = "~> 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.63.0"
    }
  }
}
