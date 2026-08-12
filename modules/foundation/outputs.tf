output "vm_id" {
  description = "Resource ID of the Compose host."
  value       = azurerm_linux_virtual_machine.host.id
}

output "vm_principal_id" {
  description = "System-assigned identity of the Compose host."
  value       = azurerm_linux_virtual_machine.host.identity[0].principal_id
}

output "backup_identity_client_id" {
  description = "Client ID selected by backup and bootstrap recovery jobs when requesting managed-identity tokens."
  value       = var.backup_identity_client_id
}

output "backup_identity_principal_id" {
  description = "Principal ID with backup-container write and bootstrap Key Vault read access."
  value       = var.backup_identity_principal_id
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.host.private_ip_address
}

output "egress_public_ip_address" {
  description = "Stable egress IP. The NSG permits no inbound connections."
  value       = azurerm_public_ip.egress.ip_address
}

output "backup_container_resource_manager_id" {
  value = azurerm_storage_container.backup.id
}

output "state_disk_id" {
  value = azurerm_managed_disk.state.id
}

output "applications_disk_id" {
  value = azurerm_managed_disk.applications.id
}
