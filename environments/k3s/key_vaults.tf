locals {
  key_vaults = {
    infra = "kv-pn-infra"
    apps  = "kv-pn-apps"
  }
}

resource "azurerm_key_vault" "k3s" {
  #checkov:skip=CKV2_AZURE_32:Public access is intentionally retained for Azure Portal administration; Azure RBAC protects the data plane.
  for_each = local.key_vaults

  name                          = each.value
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.shared.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true
  tags                          = merge(var.tags, { TrustBoundary = each.key })

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_role_assignment" "eso_infra_secrets" {
  scope                = azurerm_key_vault.k3s["infra"].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.k3s["eso"].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "eso_app_secrets" {
  scope                = azurerm_key_vault.k3s["apps"].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.k3s["eso"].principal_id
  principal_type       = "ServicePrincipal"
}

moved {
  from = azurerm_key_vault.k3s["platform"]
  to   = azurerm_key_vault.k3s["infra"]
}

moved {
  from = azurerm_role_assignment.eso_platform_secrets
  to   = azurerm_role_assignment.eso_infra_secrets
}
