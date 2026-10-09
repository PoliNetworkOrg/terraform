variable "namespace" {
  default = "traefik"
}

variable "cf_dns_api_token" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "cf_zone_api_token" {
  type      = string
  nullable  = false
  sensitive = true
}
