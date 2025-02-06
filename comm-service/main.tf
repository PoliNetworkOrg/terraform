resource "azurerm_communication_service" "comms" {
  name                = "cs-polinetwork"
  resource_group_name = var.rg_name
  data_location       = "Europe"
}