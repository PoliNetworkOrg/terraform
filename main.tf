# data "azurerm_key_vault_secret" "dev_mod_bot_token" {
#   name         = "dev-mod-bot-token"
#   key_vault_id = data.terraform_remote_state.security.outputs.key_vault_id
# }

# data "azurerm_key_vault_secret" "dev_db_host" {
#   name         = "dev-db-host"
#   key_vault_id = data.terraform_remote_state.security.outputs.key_vault_id
# }

# data "azurerm_key_vault_secret" "dev_db_password" {
#   name         = "dev-db-password"
#   key_vault_id = data.terraform_remote_state.security.outputs.key_vault_id
# }

# data "azurerm_key_vault_secret" "dev_db_user" {
#   name         = "dev-db-user"
#   key_vault_id = data.terraform_remote_state.security.outputs.key_vault_id
# }

module "argo_cd" {
  source = "./aks/"

  applications = [
    file("./argocd-applications.yaml")
  ]

  bot_token   = "a"
  db_database = "b"
  db_host     = "c"
  db_password = "d"
  db_user     = "e"

}

#export KUBE_CONFIG_PATH="~/.kube/config"