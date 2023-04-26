variable "amp_password" {
  type     = string
  nullable = false
  sensitive = true
}

variable "namespace" {
  type     = string
  nullable = false
}

variable "persistent_storage" {
  type        = bool
  description = "Volume claim for the bot"
  default     = false
}

variable "persistent_storage_location" {
  type    = string
  default = ""
}

variable "persistent_storage_rg_name" {
  type    = string
  default = ""
}

variable "persistent_storage_size_gi" {
  type        = string
  description = "Requested storage"
  default     = ""
}
