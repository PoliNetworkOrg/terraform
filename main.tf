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
  bot_onMessage = "m"
  db_database = "b"
  db_host     = "c"
  db_password = "d"
  db_user     = "e"

}

# HOW TO CONFIGURE INFRA
# - create GROUP:
# az group create --name GROUP
# - create cluster K8S:
# az aks create -g GROUP -n CLUSTER_NAME --enable-managed-identity --node-count 1 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys --node-vm-size standard_a2_v2
# - Create KeyVault:
# az keyvault create --name kv-NAME --resource-group GROUP --location "westeurope"
# - Configure kubectl
# az aks get-credentials --resource-group GROUP --name CLUSTER_NAME
# - Configure KUBE_CONFIG_PATH for kubectl
# export KUBE_CONFIG_PATH="~/.kube/config"
