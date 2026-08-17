output "kube_admin_config" {
  value     = module.aks.kube_admin_config
  sensitive = true
}

output "cluster_credentials" {
  value     = data.azurerm_kubernetes_cluster.credentials
  sensitive = true
}

output "backup_container_resource_manager_id" {
  value = module.shared.backup_container_id
}
