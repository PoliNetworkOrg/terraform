terraform {
  required_version = "~> 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}


# Kubectl provider
# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "elma-aks"
# }
