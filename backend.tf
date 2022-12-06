terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "polinetworkAPS"

    workspaces {
      name = "aks-polinetwork"
    }
  }
}
