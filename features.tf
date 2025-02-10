provider "azurerm" {
  features {}
  skip_provider_registration = true
  use_oidc                   = true
}
