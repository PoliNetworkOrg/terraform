terraform {
  required_version = "~> 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.34.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}