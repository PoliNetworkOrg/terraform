locals {
  identities = {
    eso = {
      name    = "id-k3s-eso"
      purpose = "external-secrets"
    }
    backend = {
      name    = "id-k3s-backend"
      purpose = "application-blob-access"
    }
    backup = {
      name    = "id-k3s-backup"
      purpose = "off-host-backup"
    }
  }
}

resource "azurerm_user_assigned_identity" "k3s" {
  for_each = local.identities

  name                = each.value.name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared.name
  tags                = merge(var.tags, { Purpose = each.value.purpose })
}

resource "azurerm_role_assignment" "backend_blob" {
  scope                = data.azurerm_storage_container.application.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.k3s["backend"].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "backup_blob" {
  scope                = data.azurerm_storage_container.backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.k3s["backup"].principal_id
  principal_type       = "ServicePrincipal"
}
