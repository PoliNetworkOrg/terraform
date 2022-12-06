terraform {
  cloud {
    organization = "polinetworkAPS"

    workspaces {
      name = "polinetwork-dev"
    }
  }
}