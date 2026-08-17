output "backup_container_id" {
  description = "Resource Manager ID of the retained backup container."
  value       = azurerm_storage_container.backup.id
}

output "backup_storage_account_id" {
  description = "Resource ID of the retained backup storage account."
  value       = azurerm_storage_account.backup.id
}
