terraform {
  backend "azurerm" {
    resource_group_name  = "rg-polinetwork"  # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "polinetworksa"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "terraform-state"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "state.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
    use_azuread_auth     = true                            # Can also be set via `ARM_USE_AZUREAD` environment variable.
  }
}

data "azurerm_kubernetes_cluster" "credentials" {
  name                = "aks-polinetwork"
  resource_group_name = "rg-polinetwork"
}
