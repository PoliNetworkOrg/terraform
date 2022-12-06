output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive = true
}


output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "resource_group_name" {
  value     = azurerm_resource_group.rg.name
  sensitive = true
}

output "dev_mod_bot_token" {
  value     = data.azurerm_key_vault_secret.dev_mod_bot_token.value
  sensitive = true
}

output "dev_db_host" {
  value     = data.azurerm_key_vault_secret.dev_db_host.value
  sensitive = true
}

output "dev_db_password" {
  value     = data.azurerm_key_vault_secret.dev_db_password.value
  sensitive = true
}

output "dev_db_user" {
  value     = data.azurerm_key_vault_secret.dev_db_user.value
  sensitive = true
}