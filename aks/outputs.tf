output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].host
  sensitive = true
}

output "kube_admin_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config
  sensitive = true
}

output "cluster_credentials" {
  value     = azurerm_kubernetes_cluster.k8s
  sensitive = true
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "aks_resource_group_name" {
  value = azurerm_kubernetes_cluster.k8s.resource_group_name
}
