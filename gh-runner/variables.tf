variable "runner_token" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "runner_namespace" {
  type     = string
  nullable = false
}
