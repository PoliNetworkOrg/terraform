variable "location" {
  type     = string
  nullable = false
}

variable "rg_name" {
  type     = string
  nullable = false
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed ips"
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
