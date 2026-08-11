output "kube_admin_config" {
  value     = module.aks.kube_admin_config
  sensitive = true
}

output "cluster_credentials" {
  value     = data.azurerm_kubernetes_cluster.credentials
  sensitive = true
}

output "vm_id" {
  description = "Resource ID of the Compose migration host."
  value       = module.foundation.vm_id
}

output "vm_principal_id" {
  description = "System-assigned identity of the Compose migration host."
  value       = module.foundation.vm_principal_id
}

output "backup_identity_client_id" {
  value = module.foundation.backup_identity_client_id
}

output "backup_identity_principal_id" {
  value = module.foundation.backup_identity_principal_id
}

output "private_ip_address" {
  value = module.foundation.private_ip_address
}

output "egress_public_ip_address" {
  value = module.foundation.egress_public_ip_address
}

output "backup_container_resource_manager_id" {
  value = module.foundation.backup_container_resource_manager_id
}

output "state_disk_id" {
  value = module.foundation.state_disk_id
}

output "applications_disk_id" {
  value = module.foundation.applications_disk_id
}
