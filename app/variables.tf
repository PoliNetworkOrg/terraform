variable "app_secret_token" {
  type     = string
  nullable = false
}

variable "app_namespace" {
  type     = string
  nullable = false
}

variable "db_database" {
  type     = string
  nullable = false
}

variable "db_host" {
  type      = string
  sensitive = true
  nullable  = false
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