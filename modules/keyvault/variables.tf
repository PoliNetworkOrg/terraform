variable "name" {
  type     = string
  nullable = false
}

variable "location" {
  type     = string
  nullable = false
}

variable "rg_name" {
  type     = string
  nullable = false
}

variable "tenant_id" {
  type     = string
  nullable = false
}

variable "object_id" {
  type     = string
  nullable = false
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed ips"
}

variable "openbao_identity_principal_id" {
  type        = string
  description = "Principal ID of the dedicated OpenBao managed identity."

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.openbao_identity_principal_id))
    error_message = "OpenBao identity principal ID must be a UUID."
  }
}
