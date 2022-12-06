terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "polinetworkAPS"

    workspaces {
      name = "aks-polinetwork"
    }
  }
}

data "terraform_remote_state" "aks" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "polinetworkAPS"
    workspaces = {
      name = "aks-polinetwork"
    }
  }
}
