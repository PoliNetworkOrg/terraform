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
  type      = string
  nullable  = false
  sensitive = true
}

variable "db_password" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "db_user" {
  type      = string
  nullable  = false
  sensitive = true
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

variable "git_user" {
  type      = string
  sensitive = false
  default   = ""
}

variable "git_email" {
  type      = string
  sensitive = false
  default   = ""
}
variable "git_password" {
  type      = string
  sensitive = true
  default   = ""
}
variable "git_data_repo" {
  type      = string
  sensitive = false
  default   = ""
}
variable "git_remote_repo" {
  type      = string
  sensitive = false
  default   = ""
}

variable "git_path" {
  type      = string
  sensitive = false
  default   = "/Repos"
}

variable "git_config" {
  type      = bool
  sensitive = false
  default   = false
}

variable "material_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "material_root_dir" {
  type      = string
  sensitive = false
  default   = ""
}