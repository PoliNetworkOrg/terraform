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

data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.k8s.name
  resource_group_name = azurerm_resource_group.rg.name
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config[0].cluster_ca_certificate)
  }
}
