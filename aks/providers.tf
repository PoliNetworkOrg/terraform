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
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

data "azurerm_kubernetes_cluster" "credentials" {
  name                = "aks-polinetwork"
  resource_group_name = "rg-polinetwork"
}
