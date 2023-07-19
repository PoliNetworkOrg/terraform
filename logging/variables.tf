variable "logging-namespace" {
  type    = string
  default = "logging"
}

variable "persistent_storage" {
  type        = bool
  default     = true
  description = "Logging data folder"
}

variable "persistent_storage_size_gi" {
  type        = number
  description = "(optional) Logging data size"
  default     = 100
}

variable "persistent_storage_location" {
  type = string
}

variable "persistent_storage_rg_name" {
  type = string
}

variable "openobserve_password" {
  type        = string
  description = "(optional) Openobserve password"
  default     = "password"
}