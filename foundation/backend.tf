terraform {
  backend "azurerm" {
    resource_group_name  = "rg-polinetwork"
    storage_account_name = "polinetworksa"
    container_name       = "terraform-state"
    key                  = "migration-foundation.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
