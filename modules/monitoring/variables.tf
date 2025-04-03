variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "namespace" {
  type        = string
  description = "Grafana namespace"
}

variable "cluster_monitoring_app_password" {
  type = string
}

variable "cluster_monitoring_telegram_token" {
  type = string
}
