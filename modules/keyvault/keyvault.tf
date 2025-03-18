#tfsec:ignore:azure-keyvault-specify-network-acl
resource "azurerm_key_vault" "keyvalue" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
    ip_rules       = var.allowed_ips
  }

  access_policy = [
    {
      tenant_id = var.tenant_id
      object_id = "6b6a6388-c024-450b-80b4-9dcfa474c9f0"

      key_permissions = ["Get", "List", "Update", "Create", "Import", "Delete",
        "Recover", "Backup", "Restore"
      ]

      secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup",
        "Restore"
      ]

      certificate_permissions = ["Get", "List", "Update", "Create", "Import",
        "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers",
        "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
      ]
      storage_permissions = [],
      application_id      = null
    },
    {
      key_permissions = [
        "List",
        "Get",
      ]
      object_id = "99053e08-87b6-4585-b77d-e9d2072551eb"
      secret_permissions = [
        "Get",
        "List",
      ]
      application_id          = null,
      storage_permissions     = [],
      tenant_id               = var.tenant_id,
      certificate_permissions = []
    },
    {
      certificate_permissions = []
      key_permissions = [
        "Get",
        "List",
      ]
      object_id = "81dd9fd1-ea71-420a-9f8a-8cbb74f479a6"
      secret_permissions = [
        "Get",
        "List",
      ]
      application_id      = null,
      storage_permissions = []
      tenant_id           = var.tenant_id
    },
    {
      certificate_permissions = []
      key_permissions = [
        "Get",
        "List",
      ]
      object_id = "f220ce5b-e174-413d-b6f8-04e214b85d76"
      secret_permissions = [
        "Get",
        "List",
      ]
      application_id      = null,
      storage_permissions = []
      tenant_id           = var.tenant_id
    },
    {
      certificate_permissions = []
      key_permissions = [
        "Get"
      ]
      object_id = "43fab6a8-439d-4f98-b387-682df65783f8" # Key Vault Secrets Provider
      secret_permissions = [
        "Get"
      ]
      application_id      = null
      storage_permissions = []
      tenant_id           = var.tenant_id
    },
  ]
}
