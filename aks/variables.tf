variable "location" {
  type     = string
  nullable = false
}

variable "rg_name" {
  type     = string
  nullable = false
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

variable "cert_namespace" {
  type    = string
  default = "cert-manager"
}

# variable "repo_credentials" {
#   type = list(object({
#     key           = string,
#     url           = string,
#     sshPrivateKey = string,
#     name          = string
#   }))
#   nullable = true
# }
