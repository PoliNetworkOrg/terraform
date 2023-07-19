variable "rg_name" {
  type     = string
  nullable = false
}

variable "location" {
  type     = string
  nullable = false
}

variable "persistent_storage" {
  type        = bool
  description = "Volume claim for the telegram"
  default     = false
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
