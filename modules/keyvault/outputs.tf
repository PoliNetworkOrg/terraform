output "key_vault_id" {
  value     = azurerm_key_vault.keyvalue.id
  sensitive = true
}

output "openbao_unseal_key_name" {
  value = azurerm_key_vault_key.openbao_unseal.name
}
