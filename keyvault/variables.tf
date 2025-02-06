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