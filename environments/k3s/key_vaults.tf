locals {
  key_vaults = {
    platform = "kv-polinetwork-platform"
    apps     = "kv-polinetwork-apps"
    ci       = "kv-polinetwork-ci"
  }
}

resource "azurerm_key_vault" "k3s" {
  #checkov:skip=CKV2_AZURE_32:Default-deny firewall and the K3s subnet service endpoint avoid three billed private endpoints.
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
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.k3s.id]
  }
}

resource "azurerm_role_assignment" "eso_platform_secrets" {
  scope                = azurerm_key_vault.k3s["platform"].id
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
