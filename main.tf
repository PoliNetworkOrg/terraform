resource "azurerm_resource_group" "rg" {
  name     = "rg-polinetwork"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  my_ip               = "${chomp(data.http.myip.response_body)}/32"
  elia-ip             = "185.178.95.235/32"
  mariadb_internal_ip = "10.0.10.10"
}

module "aks" {
  source = "./aks/"

  ca_tls_key = data.azurerm_key_vault_secret.ca_tls_key.value
  ca_tls_crt = data.azurerm_key_vault_secret.ca_tls_crt.value

  grafana_admin_password = data.azurerm_key_vault_secret.grafana_admin_password.value

  additional_node_pools = [{
    name       = "userpool"
    node_count = "0"
    vm_size    = "Standard_B4ms"
    mode       = "User"
  }]

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name

}

module "argo-cd" {
  depends_on = [
    module.aks
  ]

  source       = "./argocd/"
  clientId     = data.azurerm_key_vault_secret.argocd_client_id.value
  clientSecret = data.azurerm_key_vault_secret.argocd_client_secret.value
  tenant       = data.azurerm_client_config.current.tenant_id

  applications = [
    file("./argocd-applications.yaml")
  ]
}

module "gh-runner" {
  source           = "./gh-runner/"
  runner_namespace = "gh-runner"
  runner_token     = data.azurerm_key_vault_secret.gh_runner_token.value
}


module "app_dev" {
  depends_on = [
    module.mariadb
  ]

  source = "./app/"

  app_namespace    = "app-dev"
  app_secret_token = data.azurerm_key_vault_secret.dev_app_secret_token.value
  db_database      = "polinetwork_app_dev"
  db_host          = local.mariadb_internal_ip
  db_password      = data.azurerm_key_vault_secret.dev_db_password.value
  db_user          = data.azurerm_key_vault_secret.dev_db_user.value
}

module "tutorapp" {
  depends_on = [
    module.mariadb
  ]

  source             = "./tutorapp/"
  secretAuthUser     = data.azurerm_key_vault_secret.prod_tutorapp_auth_user.value
  secretAuthPassword = data.azurerm_key_vault_secret.prod_tutorapp_auth_password.value
  tutorapp_namespace = "tutor-prod"
  bot_token          = data.azurerm_key_vault_secret.prod_tutorapp_bot_token.value
  db_database        = "polimi_tutorapp"
  db_host            = local.mariadb_internal_ip
  db_user            = data.azurerm_key_vault_secret.prod_tutorapp_db_user.value
  db_password        = data.azurerm_key_vault_secret.prod_tutorapp_db_password.value
  azureSecret        = data.azurerm_key_vault_secret.prod_tutorapp_azure_secret.value
  azureClientId      = data.azurerm_key_vault_secret.prod_tutorapp_azure_clientid.value
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

  git_config      = true
  git_user        = "PoliNetworkDev"
  git_email       = data.azurerm_key_vault_secret.prod_mod_git_email.value
  git_password    = data.azurerm_key_vault_secret.prod_mod_git_password.value
  git_data_repo   = "git@github.com:PoliNetworkDev/polinetworkWebsiteData.git"
  git_remote_repo = "https://github.com/PoliNetworkOrg/polinetworkWebsiteData.git"
  git_path        = "./data/polinetworkWebsiteData/"
}

module "aule_bot" {
  depends_on = [
    module.mariadb
  ]

  source = "./bots/"

  bot_namespace = "aulebot"
  bot_token     = data.azurerm_key_vault_secret.dev_aule_bot_token.value
  bot_onMessage = "au"
  db_database   = "polinetwork_test"
  db_host       = local.mariadb_internal_ip
  db_password   = data.azurerm_key_vault_secret.dev_db_password.value
  db_user       = data.azurerm_key_vault_secret.dev_db_user.value
}

module "bot_mat_prod" {
  depends_on = [
    module.mariadb
  ]

  source = "./bots/"

  bot_namespace               = "bot-mat"
  bot_token                   = data.azurerm_key_vault_secret.prod_mat_token.value
  bot_onMessage               = "mat"
  db_database                 = "polinetwork_materials"
  db_host                     = local.mariadb_internal_ip
  db_password                 = data.azurerm_key_vault_secret.prod_mat_db_password.value
  db_user                     = data.azurerm_key_vault_secret.prod_mat_db_user.value
  persistent_storage          = true
  persistent_storage_size_gi  = "500"
  persistent_storage_location = azurerm_resource_group.rg.location
  persistent_storage_rg_name  = azurerm_resource_group.rg.name

  material_password = data.azurerm_key_vault_secret.dev_mat_config_password.value
  material_root_dir = "/Repos/"
}

module "mc" {
  depends_on = [
    module.mariadb
  ]

  source = "./mc/"

  namespace    = "mcserver"
  amp_password = data.azurerm_key_vault_secret.amp_password.value
  amp_license  = data.azurerm_key_vault_secret.amp_license.value

  persistent_storage          = true
  persistent_storage_size_gi  = "50"
  persistent_storage_location = azurerm_resource_group.rg.location
  persistent_storage_rg_name  = azurerm_resource_group.rg.name
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

  db_config = [
    {
      password = data.azurerm_key_vault_secret.dev_db_password.value
      user     = data.azurerm_key_vault_secret.dev_db_user.value
      database = "polinetwork_test"
    },
    {
      password = data.azurerm_key_vault_secret.prod_mat_db_password.value
      user     = data.azurerm_key_vault_secret.prod_mat_db_user.value
      database = "polinetwork_materials"
    },
    {
      password = data.azurerm_key_vault_secret.prod_db_password.value
      user     = data.azurerm_key_vault_secret.prod_mod_db_user.value
      database = "polinetwork"
    },
    {
      user     = data.azurerm_key_vault_secret.dev_db_user.value
      password = data.azurerm_key_vault_secret.dev_db_password.value
      database = "polinetwork_app_dev"
    },
    {
      user     = data.azurerm_key_vault_secret.dev_app_admin_db_user.value
      password = data.azurerm_key_vault_secret.dev_app_admin_db_password.value
      database = "polinetwork_app_dev"
    },
    {
      user     = data.azurerm_key_vault_secret.prod_tutorapp_db_user.value
      password = data.azurerm_key_vault_secret.prod_tutorapp_db_password.value
      database = "polimi_tutorapp"
    },
  ]

  mariadb_root_password = data.azurerm_key_vault_secret.admin_db_password.value
  mariadb_internal_ip   = local.mariadb_internal_ip

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name
}


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



# HOW TO CONFIGURE INFRA
# - create GROUP:
# az group create --name GROUP
# - create cluster K8S:
# az aks create -g GROUP -n CLUSTER_NAME --enable-managed-identity --node-count 1 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys --node-vm-size standard_a2_v2
# - Create KeyVault:
# az keyvault create --name kv-NAME --resource-group GROUP --location "westeurope"
# - Configure kubectl
# az aks get-credentials --resource-group GROUP --name CLUSTER_NAME
# - Configure kube_admin_config_PATH for kubectl
# export kube_admin_config_PATH="~/.kube/config"
