resource "azurerm_resource_group" "rg" {
  name     = "rg-polinetwork"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  my_ip               = "${chomp(data.http.myip.response_body)}/32"
  elia-ip             = "185.178.95.235/32"
  mariadb_internal_ip = "10.0.10.10"
}

module "aks" {
  source = "./aks/"

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name

}

module "argo-cd" {
  depends_on = [
    module.aks
  ]

  source = "./argocd/"

  applications = [
    file("./argocd-applications.yaml")
  ]
}

module "bot_mod_dev" {
  depends_on = [
    module.mariadb
  ]

  source = "./bots/"

  bot_namespace = "bot-dev"
  bot_token     = data.azurerm_key_vault_secret.dev_mod_bot_token.value
  bot_onMessage = "m"
  db_database   = "polinetwork_test"
  db_host       = local.mariadb_internal_ip
  db_password   = data.azurerm_key_vault_secret.dev_db_password.value
  db_user       = data.azurerm_key_vault_secret.dev_db_user.value
}

module "bot_mod_prod" {
  depends_on = [
    module.mariadb
  ]

  source = "./bots/"

  bot_namespace = "bot-prod"
  bot_token     = data.azurerm_key_vault_secret.prod_mod_bot_token.value
  bot_onMessage = "m"
  db_database   = "polinetwork"
  db_host       = local.mariadb_internal_ip
  db_password   = data.azurerm_key_vault_secret.prod_db_password.value
  db_user       = data.azurerm_key_vault_secret.prod_mod_db_user.value
}

module "bot_mat_prod" {
  depends_on = [
    module.mariadb
  ]

  source = "./bots/"

  bot_namespace               = "bot-mat"
  bot_token                   = data.azurerm_key_vault_secret.prod_bot_mat_token.value
  bot_onMessage               = "mat"
  db_database                 = "polinetwork_materials"
  db_host                     = local.mariadb_internal_ip
  db_password                 = data.azurerm_key_vault_secret.prod_bot_mat_db_password.value
  db_user                     = data.azurerm_key_vault_secret.prod_bot_mat_db_user.value
  persistent_storage          = true
  persistent_storage_size_gi  = "500"
  persistent_storage_location = azurerm_resource_group.rg.location
  persistent_storage_rg_name  = azurerm_resource_group.rg.name

  # git_config = true
  # git_user = "PoliNetworkDev"
  # git_email = data.azurerm_key_vault_secret.dev_mod_git_email.value
  # git_password = data.azurerm_key_vault_secret.dev_bot_mat_git_password.value
  # git_data_repo = "github.com/PoliNetworkDev/polinetworkWebsiteData.git"
  # git_remote_repo = "github.com/PoliNetworkOrg/polinetworkWebsiteData.git"
  # git_path = "./data/polinetworkWebsiteData/"
}


module "keyvault" {
  source = "./keyvault/"

  name = "kv-polinetwork"

  location  = azurerm_resource_group.rg.location
  rg_name   = azurerm_resource_group.rg.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  allowed_ips = []
}

module "mariadb" {
  depends_on = [
    module.aks,
    module.argo-cd
  ]

  source = "./mariadb/"

  dev_db_password       = data.azurerm_key_vault_secret.dev_db_password.value
  dev_db_user           = data.azurerm_key_vault_secret.dev_db_user.value
  dev_db_database       = "polinetwork_test"
  prod_db_password      = data.azurerm_key_vault_secret.prod_db_password.value
  prod_db_user          = data.azurerm_key_vault_secret.prod_mod_db_user.value
  prod_db_database      = "polinetwork"
  mat_db_password       = data.azurerm_key_vault_secret.prod_bot_mat_db_password.value
  mat_db_user           = data.azurerm_key_vault_secret.prod_bot_mat_db_user.value
  mat_db_database       = "polinetwork_materials"
  mariadb_root_password = data.azurerm_key_vault_secret.admin_db_password.value
  mariadb_internal_ip   = local.mariadb_internal_ip

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name
}

# data "azurerm_key_vault_secret" "dev_mat_git_email" {
#   name         = "dev-bot-mat-git-email"
#   key_vault_id = module.keyvault.key_vault_id
# }

# data "azurerm_key_vault_secret" "dev_mat_git_password" {
#   name         = "dev-bot-mat-git-password"
#   key_vault_id = module.keyvault.key_vault_id
# }

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

data "azurerm_key_vault_secret" "prod_bot_mat_token" {
  name         = "prod-bot-mat-token"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_bot_mat_db_password" {
  name         = "prod-bot-mat-db-password"
  key_vault_id = module.keyvault.key_vault_id
}

data "azurerm_key_vault_secret" "prod_bot_mat_db_user" {
  name         = "prod-bot-mat-db-user"
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
