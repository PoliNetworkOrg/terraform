module "argo_cd" {
  source = "./aks/"

  applications = [
    file("./argocd-applications.yaml")
  ]

  dev_bot_token     = module.argo_cd.dev_mod_bot_token
  dev_bot_onMessage = "m"
  dev_db_database   = "polinetwork_test"
  dev_db_host       = module.argo_cd.dev_db_host
  dev_db_password   = module.argo_cd.dev_db_password
  dev_db_user       = module.argo_cd.dev_db_user

  prod_bot_token     = module.argo_cd.prod_mod_bot_token
  prod_bot_onMessage = "m"
  prod_db_database   = "polinetwork"
  prod_db_host       = module.argo_cd.dev_db_host
  prod_db_password   = module.argo_cd.dev_db_password
  prod_db_user       = module.argo_cd.dev_db_user
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
