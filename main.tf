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
  mariadb_internal_ip = "mariadb-service.mariadb.svc.cluster.local"
}

module "aks" {
  source = "./modules/aks/"

  ca_tls_key = data.azurerm_key_vault_secret.ca_tls_key.value
  ca_tls_crt = data.azurerm_key_vault_secret.ca_tls_crt.value

  additional_node_pools = [
    {
      name                = "supportpool"
      min_count           = 0
      max_count           = 0
      node_count          = 0
      enable_auto_scaling = false
      vm_size             = "Standard_B2s"
      mode                = "User"
    }
  ]

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name

  kubernetes_orchestrator_version = "1.26.3"

}

module "argo-cd" {
  depends_on = [
    module.aks
  ]

  source       = "./modules/argocd/"
  clientId     = data.azurerm_key_vault_secret.argocd_client_id.value
  clientSecret = data.azurerm_key_vault_secret.argocd_client_secret.value
  tenant       = data.azurerm_client_config.current.tenant_id

  applications = [
    file("./argocd-applications.yaml")
  ]
}

module "cloudflare" {
  depends_on = [
    module.aks
  ]

  source       = "./modules/cloudflare/"
  tunnel_token = data.azurerm_key_vault_secret.cloudflare_tunnel_token.value
}

module "app_dev" {
  depends_on = [
    module.mariadb
  ]

  source = "./modules/app/"

  app_namespace    = "app-dev"
  app_secret_token = data.azurerm_key_vault_secret.dev_app_secret_token.value
  db_database      = "polinetwork_app_dev"
  db_host          = local.mariadb_internal_ip
  db_password      = data.azurerm_key_vault_secret.dev_db_password.value
  db_user          = data.azurerm_key_vault_secret.dev_db_user.value
}

module "monitoring" {
  depends_on = [
    module.aks
  ]

  source = "./modules/monitoring/"

  namespace = "monitoring"

  cluster_monitoring_app_password   = data.azurerm_key_vault_secret.cluster_monitoring_app_password.value
  cluster_monitoring_telegram_token = data.azurerm_key_vault_secret.cluster_monitoring_telegram_token.value

  grafana_admin_password      = data.azurerm_key_vault_secret.grafana_admin_password.value
  persistent_storage          = true
  persistent_storage_size_gi  = "10"
  persistent_storage_location = azurerm_resource_group.rg.location
  persistent_storage_rg_name  = azurerm_resource_group.rg.name
}

module "bot_mod_prod" {
  depends_on = [
    module.mariadb
  ]

  source = "./modules/bots/"

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

module "bot_mat_migration" {
  depends_on = [
    module.mariadb
  ]

  source = "./modules/bots/"

  bot_namespace               = "bot-mat"
  bot_token                   = data.azurerm_key_vault_secret.prod_mat_token.value
  bot_onMessage               = "mat"
  db_database                 = "polinetwork_materials"
  db_host                     = local.mariadb_internal_ip
  db_password                 = data.azurerm_key_vault_secret.prod_mat_db_password.value
  db_user                     = data.azurerm_key_vault_secret.prod_mat_db_user.value
  persistent_storage          = true
  persistent_storage_size_gi  = "250"
  persistent_storage_location = azurerm_resource_group.rg.location
  persistent_storage_rg_name  = azurerm_resource_group.rg.name

  material_password = data.azurerm_key_vault_secret.dev_mat_config_password.value
  material_root_dir = "/Repos/"
}

module "keyvault" {
  source = "./modules/keyvault/"

  name = "kv-polinetwork"

  location  = azurerm_resource_group.rg.location
  rg_name   = azurerm_resource_group.rg.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  allowed_ips = []
}

module "storageaccount" {
  source = "./modules/storage"

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name

}

module "mariadb" {
  depends_on = [
    module.aks,
    module.argo-cd
  ]

  source = "./modules/mariadb/"

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
      user     = data.azurerm_key_vault_secret.dev_newbot_db_user.value
      password = data.azurerm_key_vault_secret.dev_newbot_db_password.value
      database = "polinetwork_newbot_dev"
    }
  ]

  mariadb_root_password = data.azurerm_key_vault_secret.admin_db_password.value
  mariadb_internal_ip   = local.mariadb_internal_ip

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name
}

