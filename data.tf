
data "azurerm_key_vault_secret" "amp_password" {
  name         = "mc-amp-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "amp_license" {
  name         = "mc-amp-license"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "grafana_admin_password" {
  name         = "grafana-admin-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_aule_bot_token" {
  name         = "dev-aule-bot-token"
  key_vault_id = module.keyvault.key_vault_id
}


data "azurerm_key_vault_secret" "prod_tutorapp_azure_secret" {
  name         = "prod-tutorapp-azure-secret"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_tutorapp_azure_clientid" {
  name         = "prod-tutorapp-azure-client-id"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_mod_git_email" {
  name         = "prod-mod-git-email"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_mod_git_password" {
  name         = "bot-prod-git-ssh-key"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "gh_runner_token" {
  name         = "gh-runner-token"
  key_vault_id = module.keyvault.key_vault_id
}


data "azurerm_key_vault_secret" "ca_tls_crt" {
  name         = "ca-crt"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "ca_tls_key" {
  name         = "ca-key"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "argocd_client_secret" {
  name         = "argocd-client-secret"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "argocd_client_id" {
  name         = "argocd-client-id"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_tutorapp_auth_user" {
  name         = "prod-tutorapp-auth-user"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_tutorapp_auth_password" {
  name         = "prod-tutorapp-auth-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_tutorapp_db_user" {
  name         = "prod-tutorapp-db-user"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_tutorapp_bot_token" {
  name         = "prod-tutorapp-bot-token"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_tutorapp_db_password" {
  name         = "prod-tutorapp-db-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_app_admin_db_user" {
  name         = "dev-app-admin-db-user"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_app_admin_db_password" {
  name         = "dev-app-admin-db-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_app_secret_token" {
  name         = "dev-app-secret-token"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_mat_config_password" {
  name         = "dev-mat-config-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_mod_bot_token" {
  name         = "dev-mod-bot-token"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_mod_bot_token" {
  name         = "prod-mod-bot-token"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_db_host" {
  name         = "dev-db-host"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_db_password" {
  name         = "dev-db-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_db_user" {
  name         = "dev-db-user"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "admin_db_password" {
  name         = "admin-db-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_db_password" {
  name         = "prod-db-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_mod_db_user" {
  name         = "prod-mod-db-user"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_mat_token" {
  name         = "prod-bot-mat-token"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_mat_db_password" {
  name         = "prod-bot-mat-db-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_mat_db_user" {
  name         = "prod-mat-db-user"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "cluster_monitoring_app_password" {
  name         = "cluster-monitoring-app-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "cluster_monitoring_telegram_token" {
  name         = "cluster-monitoring-telegram-token"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "elasticsearch_password" {
  name         = "elasticsearch-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_newbot_db_user" {
  name         = "dev-newbot-db-user"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "dev_newbot_db_password" {
  name         = "dev-newbot-db-password"
  key_vault_id = module.keyvault.key_vault_id
}
