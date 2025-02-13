variable "namespace" {
  default = "cloudflare"
}

variable "tunnel_token" {
  type      = string
  nullable  = false
  sensitive = true
}
