resource "azurerm_resource_group" "rg" {
  name     = "rg-polinetwork"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  my_ip   = "${chomp(data.http.myip.response_body)}/32"
  elia-ip = "185.178.95.235/32"
}

module "aks" {
  source = "./aks/"

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name

  allowed_ips = [local.elia-ip, local.my_ip]
}

module "argo-cd" {
  source = "./argocd/"

  applications = [
    file("./argocd-applications.yaml")
  ]
}

module "bots" {
  source = "./bots/"

  dev_bot_token     = data.azurerm_key_vault_secret.dev_mod_bot_token.value
  dev_bot_onMessage = "m"
  dev_db_database   = "polinetwork_test"
  dev_db_host       = data.azurerm_key_vault_secret.dev_db_host.value
  dev_db_password   = data.azurerm_key_vault_secret.dev_db_password.value
  dev_db_user       = data.azurerm_key_vault_secret.dev_db_user.value

  prod_bot_token     = data.azurerm_key_vault_secret.prod_mod_bot_token.value
  prod_bot_onMessage = "m"
  prod_db_database   = "polinetwork"
  prod_db_host       = data.azurerm_key_vault_secret.dev_db_host.value
  prod_db_password   = data.azurerm_key_vault_secret.dev_db_password.value
  prod_db_user       = data.azurerm_key_vault_secret.dev_db_user.value
}

module "keyvault" {
  source = "./keyvault/"

  name = "kv-polinetwork"

  location = azurerm_resource_group.rg.location

  rg_name   = azurerm_resource_group.rg.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  allowed_ips = [local.elia-ip, local.my_ip]
}

module "mysql" {
  source = "./mysql/"

  persistent_volume_name = module.aks.kubernetes_persistent_volume

  dev_db_password     = data.azurerm_key_vault_secret.dev_db_password.value
  dev_db_user         = data.azurerm_key_vault_secret.dev_db_user.value
  prod_db_password    = data.azurerm_key_vault_secret.dev_db_password.value
  prod_db_user        = data.azurerm_key_vault_secret.dev_db_user.value
  dev_db_database     = "polinetwork_test"
  prod_db_database    = "polinetwork"
  mysql_root_password = data.azurerm_key_vault_secret.admin_db_password.value
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
