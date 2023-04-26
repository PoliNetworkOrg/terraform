variable "location" {
  type     = string
  nullable = false
}

variable "rg_name" {
  type     = string
  nullable = false
}

variable "ca_tls_crt" {
  type = string
  sensitive = true
}

variable "ca_tls_key" {
  type = string
  sensitive = true
}

variable "grafana_admin_password" {
  type = string
  sensitive = true
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
