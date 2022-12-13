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
    default_action = "Deny"
    ip_rules       = var.allowed_ips
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

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
  }
}