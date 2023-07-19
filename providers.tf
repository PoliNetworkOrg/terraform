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
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.3.0"
    }
  }
}


provider "helm" {
  debug = true
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_admin_config[0].cluster_ca_certificate)
}