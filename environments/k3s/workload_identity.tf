# Self-hosted OIDC issuer for K3s service-account tokens. Entra ID fetches the
# discovery document and JWKS anonymously, so they live in a dedicated account
# whose only public container holds these two non-secret documents.
locals {
  k3s_oidc_issuer = "https://${azurerm_storage_account.oidc.name}.blob.core.windows.net/${azurerm_storage_container.oidc.name}"

  # Federated subjects are exact service accounts, never namespace wildcards.
  federated_service_accounts = {
    eso = "system:serviceaccount:external-secrets:keyvault-reader"
  }
}

resource "azurerm_storage_account" "oidc" {
  #checkov:skip=CKV_AZURE_190:The OIDC container must allow anonymous blob reads for Entra ID discovery.
  #checkov:skip=CKV_AZURE_59:Entra ID fetches the issuer documents over the public endpoint.
  #checkov:skip=CKV_AZURE_33:Blob-only account; the queue service is unused.
  #checkov:skip=CKV_AZURE_206:LRS is enough for documents reproducible from Git and the K3s datastore.
  name                            = "pnk3soidc"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.shared.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = true
  # Account keys could rewrite the JWKS; writes need Entra data roles instead.
  shared_access_key_enabled = false
  tags                      = merge(var.tags, { Purpose = "k3s-oidc-issuer" })

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

# Terraform reads and writes the issuer documents with Entra ID. The plan
# identity can only read them; only the apply identity can replace the JWKS.
locals {
  oidc_document_roles = {
    plan  = { principal_id = var.terraform_plan_principal_id, role = "Storage Blob Data Reader" }
    apply = { principal_id = var.terraform_apply_principal_id, role = "Storage Blob Data Contributor" }
  }
}

resource "azurerm_role_assignment" "oidc_documents" {
  for_each = local.oidc_document_roles

  scope                = azurerm_storage_account.oidc.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
  principal_type       = "ServicePrincipal"
}

# Created out of band so the pull request plan could read the documents
# before these assignments existed in state.
import {
  to = azurerm_role_assignment.oidc_documents["plan"]
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-polinetwork/providers/Microsoft.Storage/storageAccounts/pnk3soidc/providers/Microsoft.Authorization/roleAssignments/30f20fa3-00b3-493d-83ea-6306a65122e9"
}

import {
  to = azurerm_role_assignment.oidc_documents["apply"]
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-polinetwork/providers/Microsoft.Storage/storageAccounts/pnk3soidc/providers/Microsoft.Authorization/roleAssignments/df7e6941-8479-4f7b-b585-abf6daf52344"
}

resource "azurerm_storage_container" "oidc" {
  #checkov:skip=CKV_AZURE_34:Entra ID reads the issuer documents anonymously.
  name                  = "oidc"
  storage_account_id    = azurerm_storage_account.oidc.id
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "oidc_discovery" {
  name                   = ".well-known/openid-configuration"
  storage_account_name   = azurerm_storage_account.oidc.name
  storage_container_name = azurerm_storage_container.oidc.name
  type                   = "Block"
  content_type           = "application/json"
  source_content = jsonencode({
    issuer                                = local.k3s_oidc_issuer
    jwks_uri                              = "${local.k3s_oidc_issuer}/openid/v1/jwks"
    response_types_supported              = ["id_token"]
    subject_types_supported               = ["public"]
    id_token_signing_alg_values_supported = ["RS256"]
  })
}

# Public half of the K3s service-account signing key, copied from
# `k3s kubectl get --raw /openid/v1/jwks`. The key lives in the K3s datastore,
# so a restore from the control-plane backup keeps it; a rebuilt cluster with a
# new key must update this file before workload identity works again.
resource "azurerm_storage_blob" "oidc_jwks" {
  name                   = "openid/v1/jwks"
  storage_account_name   = azurerm_storage_account.oidc.name
  storage_container_name = azurerm_storage_container.oidc.name
  type                   = "Block"
  content_type           = "application/json"
  source_content         = jsonencode(jsondecode(file("${path.module}/k3s-service-account-jwks.json")))
}

resource "azurerm_federated_identity_credential" "k3s" {
  for_each = local.federated_service_accounts

  name                = "k3s-${each.key}"
  resource_group_name = data.azurerm_resource_group.shared.name
  parent_id           = azurerm_user_assigned_identity.k3s[each.key].id
  issuer              = local.k3s_oidc_issuer
  subject             = each.value
  audience            = ["api://AzureADTokenExchange"]
}
