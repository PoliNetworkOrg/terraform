variable "persistent_storage" {
  type        = bool
  description = "Volume claim for the bot"
  default     = false
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
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

variable "namespace" {
  type        = string
  description = "Grafana namespace"
}

variable "cluster_monitoring_app_password" {
  type = string
}

variable "cluster_monitoring_telegram_token" {
  type = string
}