variable "resource_group_name" {
  description = "Name of the resource group shared by the legacy and K3s environments."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID used as the scope for shared budgets."
  type        = string
}

variable "location" {
  description = "Azure region of the shared resources."
  type        = string
}

variable "allowed_subnet_ids" {
  description = "Subnets permitted by the backup storage firewall."
  type        = set(string)
}

variable "backup_storage_account_name" {
  description = "Globally unique storage account dedicated to off-host backups."
  type        = string
  default     = "polinetworkbackups"
}

variable "budget_start_date" {
  description = "First day of the month from which the recurring resource-group budget is enforced."
  type        = string
  default     = "2026-09-01T00:00:00Z"
}

variable "monthly_budget_amount_usd" {
  description = "Monthly operating target used to detect abnormal spend early."
  type        = number
  default     = 140
}

variable "annual_budget_amount_usd" {
  description = "Annual safety ceiling below the USD 2,000 sponsorship."
  type        = number
  default     = 1850
}

variable "budget_contact_emails" {
  description = "Recipients for actual and forecast Azure budget alerts."
  type        = set(string)
  default     = ["adminorg@polinetwork.org"]
}

variable "tags" {
  description = "Tags applied to shared resources."
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
    Migration   = "aks-to-compose"
    Owner       = "PoliNetwork"
  }
}
