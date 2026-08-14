output "vm_name" {
  description = "Hostname used by the Ansible inventory."
  value       = azurerm_linux_virtual_machine.k3s.name
}

output "vm_resource_id" {
  description = "Azure resource ID used by break-glass automation."
  value       = azurerm_linux_virtual_machine.k3s.id
}

output "private_ip_address" {
  description = "Private VM address reached through Cloudflare Access or an operator tunnel."
  value       = azurerm_network_interface.k3s.private_ip_address
}

output "availability_zone" {
  description = "Zone shared by compute and data disks."
  value       = azurerm_linux_virtual_machine.k3s.zone
}

output "data_disk_ids" {
  description = "Data disk resource IDs keyed by their Ansible mount role."
  value = {
    fast     = azurerm_managed_disk.fast.id
    standard = azurerm_managed_disk.standard.id
  }
}

output "managed_identity_client_ids" {
  description = "Non-secret client IDs selected by K3s workloads."
  value = {
    for name, identity in azurerm_user_assigned_identity.k3s : name => identity.client_id
  }
}

output "key_vault_uris" {
  description = "Vault endpoints consumed by External Secrets configuration."
  value = {
    for name, vault in azurerm_key_vault.k3s : name => vault.vault_uri
  }
}

output "backup_container_resource_manager_id" {
  description = "Existing backup container retained outside this state."
  value       = data.azurerm_storage_container.backup.id
}
