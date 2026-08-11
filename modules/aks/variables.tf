variable "rg_location" {
  type     = string
  nullable = false
}

variable "rg_name" {
  type     = string
  nullable = false
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID used to scope custom roles"
  nullable    = false
}

variable "ca_tls_crt" {
  type      = string
  sensitive = true
}

variable "ca_tls_key" {
  type      = string
  sensitive = true
}

variable "additional_node_pools" {
  type = list(object({
    name                = string
    vm_size             = string
    node_count          = string
    max_count           = number
    min_count           = number
    enable_auto_scaling = bool
    tags                = optional(map(string))
    mode                = optional(string)
  }))
  default = []
}

variable "kubernetes_orchestrator_version" {
  type        = string
  description = "Kubernetes version"
}
