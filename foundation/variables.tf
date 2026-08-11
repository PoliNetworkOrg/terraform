variable "resource_group_name" {
  description = "Existing resource group that hosts the current and migration infrastructure."
  type        = string
  default     = "rg-polinetwork"
}

variable "location" {
  description = "Azure region approved by the migration plan."
  type        = string
  default     = "westeurope"

  validation {
    condition     = var.location == "westeurope"
    error_message = "The migration is costed and approved only for West Europe."
  }
}

variable "vm_size" {
  description = "ARM64 VM SKU approved by the cost and capacity gates."
  type        = string
  default     = "Standard_E2ps_v5"

  validation {
    condition     = var.vm_size == "Standard_E2ps_v5"
    error_message = "Automatic fallback to a larger or x86 SKU is forbidden."
  }
}

variable "admin_username" {
  description = "Local break-glass administrator. The NSG exposes no SSH ingress."
  type        = string
  default     = "pnadmin"
}

variable "backup_storage_account_name" {
  description = "Globally unique storage account dedicated to off-host backups."
  type        = string
  default     = "polinetworkbackup"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.backup_storage_account_name))
    error_message = "Azure storage account names must contain 3-24 lowercase letters or digits."
  }
}

variable "budget_start_date" {
  description = "First day of the month from which the recurring resource-group budget is enforced."
  type        = string
  default     = "2026-09-01T00:00:00Z"

  validation {
    condition     = can(regex("^[0-9]{4}-[0-9]{2}-01T00:00:00Z$", var.budget_start_date))
    error_message = "The Azure budget start date must be the first day of a month in UTC."
  }
}

variable "monthly_budget_amount_usd" {
  description = "Absolute monthly ceiling corresponding to approximately USD 2,000/year."
  type        = number
  default     = 166

  validation {
    condition     = var.monthly_budget_amount_usd <= 166.67
    error_message = "The budget must not exceed the USD 2,000/year sponsorship ceiling."
  }
}

variable "budget_contact_emails" {
  description = "Recipients for actual and forecast Azure budget alerts."
  type        = set(string)
  default     = ["adminorg@polinetwork.org"]

  validation {
    condition     = length(var.budget_contact_emails) > 0
    error_message = "At least one budget notification recipient is required."
  }
}

variable "tags" {
  description = "Tags applied to every migration resource."
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
    Migration   = "aks-to-compose"
    Owner       = "PoliNetwork"
  }
}
