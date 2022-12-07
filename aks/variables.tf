variable "namespace" {
  default = "argocd"
}

variable "applications" {
  type        = list(string)
  nullable    = true
  description = "List of applications to deploy, see https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps"
}

variable "dev_bot_token" {
  type     = string
  nullable = false
}

variable "dev_bot_onMessage" {
  type     = string
  nullable = false
}

variable "dev_db_database" {
  type     = string
  nullable = false
}

variable "dev_db_host" {
  type     = string
  nullable = false
}

variable "dev_db_password" {
  type     = string
  nullable = false
}

variable "dev_db_user" {
  type     = string
  nullable = false
}

variable "prod_bot_token" {
  type     = string
  nullable = false
}

variable "prod_bot_onMessage" {
  type     = string
  nullable = false
}

variable "prod_db_database" {
  type     = string
  nullable = false
}

variable "prod_db_host" {
  type     = string
  nullable = false
}

variable "prod_db_password" {
  type     = string
  nullable = false
}

variable "prod_db_user" {
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
