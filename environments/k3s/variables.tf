variable "subscription_id" {
  description = "Azure subscription that contains the shared PoliNetwork resource group."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be an Azure subscription UUID."
  }
}

variable "admin_ssh_public_key" {
  description = "OpenSSH public key for the break-glass VM administrator. Pass it through TF_VAR_admin_ssh_public_key; it is not read from Key Vault."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = can(regex("^ssh-(ed25519|rsa|ecdsa-[^ ]+) [A-Za-z0-9+/=]+(?: .*)?$", trimspace(var.admin_ssh_public_key)))
    error_message = "admin_ssh_public_key must be a supported OpenSSH public key."
  }
}

variable "location" {
  description = "Azure region approved by the migration plan."
  type        = string
  default     = "West Europe"

  validation {
    condition     = lower(replace(var.location, " ", "")) == "westeurope"
    error_message = "The K3s target is approved only for West Europe."
  }
}

variable "availability_zone" {
  description = "Availability Zone shared by the VM and both data disks."
  type        = string
  default     = "1"

  validation {
    condition     = contains(["1", "2", "3"], var.availability_zone)
    error_message = "availability_zone must be 1, 2, or 3."
  }
}

variable "resource_group_name" {
  description = "Existing resource group shared with the legacy environment."
  type        = string
  default     = "rg-polinetwork"
}

variable "platform_storage_account_name" {
  description = "Existing storage account that owns the application Blob container."
  type        = string
  default     = "polinetworksa"
}

variable "application_blob_container_name" {
  description = "Existing Blob container used by the backend."
  type        = string
  default     = "file-blobs"
}

variable "backup_storage_account_name" {
  description = "Existing ZRS storage account retained from the failed migration."
  type        = string
  default     = "polinetworkbackups"
}

variable "backup_container_name" {
  description = "Existing off-host backup container."
  type        = string
  default     = "backups"
}

variable "vm_size" {
  description = "ARM64 VM SKU selected by the migration capacity assessment."
  type        = string
  default     = "Standard_E2ps_v6"

  validation {
    condition     = var.vm_size == "Standard_E2ps_v6"
    error_message = "The migration does not allow an implicit VM SKU fallback."
  }
}

variable "admin_username" {
  description = "Break-glass administrator used by Ansible after provisioning."
  type        = string
  default     = "pnadmin"
}

variable "tags" {
  description = "Tags applied to resources owned by the K3s state."
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
    Migration   = "aks-to-k3s"
    Owner       = "PoliNetwork"
  }
}
