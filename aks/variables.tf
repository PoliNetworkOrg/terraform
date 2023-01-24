variable "location" {
  type     = string
  nullable = false
}

variable "rg_name" {
  type     = string
  nullable = false
}

variable "ca_tls_crt" {
  type     = string
  nullable = false
}

variable "ca_tls_key" {
  type     = string
  nullable = false
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
