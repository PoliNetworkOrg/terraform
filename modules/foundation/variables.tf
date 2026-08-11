variable "rg_name" {
  description = "Name of the resource group shared with the existing infrastructure."
  type        = string
}

variable "rg_id" {
  description = "Resource ID of the shared resource group."
  type        = string
}

variable "location" {
  description = "Azure region approved by the migration plan."
  type        = string

  validation {
    condition     = lower(replace(var.location, " ", "")) == "westeurope"
    error_message = "The migration is costed and approved only for West Europe."
  }
}

variable "ssh_public_key" {
  description = "Public SSH key read by the root module from the organization Key Vault."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-(ed25519|rsa|ecdsa-[^ ]+) ", trimspace(var.ssh_public_key)))
    error_message = "The VM administrator key must be a supported OpenSSH public key."
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

  validation {
    condition     = var.admin_username == "pnadmin"
    error_message = "The approved VM administrator username is pnadmin."
  }
}

variable "backup_storage_account_name" {
  description = "Globally unique storage account dedicated to off-host backups."
  type        = string
  default     = "polinetworkbackups"

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
    condition = (
      can(formatdate("YYYY-MM-DD", var.budget_start_date)) &&
      can(regex("^[0-9]{4}-(0[1-9]|1[0-2])-01T00:00:00Z$", var.budget_start_date))
    )
    error_message = "The Azure budget start date must be the first day of a month in UTC."
  }
}

variable "monthly_budget_amount_usd" {
  description = "Monthly operating target used to detect abnormal spend early."
  type        = number
  default     = 140

  validation {
    condition     = var.monthly_budget_amount_usd > 0 && var.monthly_budget_amount_usd <= (2000 / 12)
    error_message = "The monthly budget must be positive and must not annualize above the USD 2,000 sponsorship ceiling."
  }
}

variable "annual_budget_amount_usd" {
  description = "Annual safety ceiling that preserves contingency below the USD 2,000 sponsorship."
  type        = number
  default     = 1850

  validation {
    condition     = var.annual_budget_amount_usd > 0 && var.annual_budget_amount_usd <= 1850
    error_message = "The annual safety budget must be positive and retain at least USD 150 below the sponsorship ceiling."
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
