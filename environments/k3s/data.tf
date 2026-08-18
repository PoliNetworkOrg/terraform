data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "shared" {
  name = var.resource_group_name
}

data "azurerm_key_vault" "legacy" {
  name                = "kv-polinetwork"
  resource_group_name = data.azurerm_resource_group.shared.name
}

data "azurerm_key_vault_secret" "admin_ssh_public_key" {
  name         = "compose-vm-ssh-public-key"
  key_vault_id = data.azurerm_key_vault.legacy.id
}

data "azurerm_storage_account" "platform" {
  name                = var.platform_storage_account_name
  resource_group_name = data.azurerm_resource_group.shared.name
}

data "azurerm_storage_container" "application" {
  name               = var.application_blob_container_name
  storage_account_id = data.azurerm_storage_account.platform.id
}

data "azurerm_storage_account" "backup" {
  name                = var.backup_storage_account_name
  resource_group_name = data.azurerm_resource_group.shared.name
}

data "azurerm_storage_container" "backup" {
  name               = var.backup_container_name
  storage_account_id = data.azurerm_storage_account.backup.id
}
