variable "tutorapp_namespace" {
  type     = string
  nullable = false
}

variable "azureSecret" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "azureClientId" {
  type     = string
  nullable = false
}

variable "bot_token" {
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

variable "secretAuthUser" {
  type      = string
  nullable  = false
  sensitive = true

}

variable "secretAuthPassword" {
  type      = string
  nullable  = false
  sensitive = true

}