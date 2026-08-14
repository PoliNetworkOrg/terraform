resource "azurerm_storage_account" "backup" {
  #checkov:skip=CKV_AZURE_206:ZRS meets the approved backup threat model at lower cost than geo-replication.
  #checkov:skip=CKV_AZURE_59:The public endpoint is protected by a default-deny firewall and approved subnet service endpoints.
  #checkov:skip=CKV2_AZURE_33:Storage service endpoints avoid a billed private endpoint for the single-host target.
  #checkov:skip=CKV_AZURE_36:Only explicitly approved subnets can cross the storage firewall; trusted-service bypass stays disabled.
  #checkov:skip=CKV_AZURE_33:This dedicated account uses Blob only and has no Queue workload to audit.
  #checkov:skip=CKV2_AZURE_1:Platform-managed keys plus infrastructure encryption and encrypted archives avoid a Key Vault recovery dependency.
  #checkov:skip=CKV2_AZURE_40:Shared-key access is retained temporarily for the existing Zerobyte client and is removed with the failed migration.
  #checkov:skip=CKV2_AZURE_41:The retained client does not issue SAS tokens; the K3s identities use Azure RBAC instead.
  name                              = var.backup_storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "ZRS"
  account_kind                      = "StorageV2"
  access_tier                       = "Cool"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  public_network_access_enabled     = true
  shared_access_key_enabled         = true
  default_to_oauth_authentication   = true
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true
  local_user_enabled                = false
  tags                              = merge(var.tags, { DataClass = "backup" })

  network_rules {
    default_action             = "Deny"
    bypass                     = ["None"]
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "backup" {
  #checkov:skip=CKV2_AZURE_21:Backup job-age and success alerts are used instead of per-read Log Analytics ingestion.
  name                  = "backups"
  storage_account_id    = azurerm_storage_account.backup.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "zerobyte" {
  #checkov:skip=CKV2_AZURE_21:Zerobyte health and repository checks are used instead of per-read Log Analytics ingestion.
  name                  = "zerobyte"
  storage_account_id    = azurerm_storage_account.backup.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container_immutability_policy" "backup" {
  storage_container_resource_manager_id = azurerm_storage_container.backup.id
  immutability_period_in_days           = 30
  protected_append_writes_enabled       = true
}

resource "azurerm_storage_management_policy" "backup" {
  storage_account_id = azurerm_storage_account.backup.id

  rule {
    name    = "backup-retention"
    enabled = true

    filters {
      prefix_match = ["backups/"]
      blob_types   = ["blockBlob", "appendBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }

      snapshot {
        delete_after_days_since_creation_greater_than = 90
      }

      version {
        delete_after_days_since_creation = 90
      }
    }
  }
}

resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "budget-rg-polinetwork-monthly"
  resource_group_id = var.resource_group_id
  amount            = var.monthly_budget_amount_usd
  time_grain        = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 85
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 120
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }
}

resource "azurerm_consumption_budget_resource_group" "annual" {
  name              = "budget-rg-polinetwork-annual-safety"
  resource_group_id = var.resource_group_id
  amount            = var.annual_budget_amount_usd
  time_grain        = "Annually"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 75
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 85
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 95
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }
}
