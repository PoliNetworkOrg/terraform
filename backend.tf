terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "polinetworkAPS"

    workspaces {
      name = "aks-polinetwork"
    }
  }
}

data "azurerm_kubernetes_cluster" "credentials" {
  name                = "aks-polinetwork"
  resource_group_name = "rg-polinetwork"
}