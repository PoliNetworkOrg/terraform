terraform {
  cloud {
    organization = "polinetworkAPS"

    workspaces {
      name = "aks-polinetwork"
    }
  }
}
