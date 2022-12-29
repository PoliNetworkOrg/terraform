variable "bot_token" {
  type     = string
  nullable = false
}

variable "bot_namespace" {
  type     = string
  nullable = false
}

variable "bot_onMessage" {
  type     = string
  nullable = false
}

variable "db_database" {
  type     = string
  nullable = false
}

variable "db_host" {
  type     = string
  nullable = false
}

variable "db_password" {
  type     = string
  nullable = false
}

variable "db_user" {
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
