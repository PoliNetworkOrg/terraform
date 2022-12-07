resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "bot" {
  metadata {
    name = "bot"
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.5.7"
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    templatefile("${path.module}/values/argo_cd.tftpl", {
      # repo_credentials  = var.repo_credentials
    })
  ]
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = true

  values = var.applications

  depends_on = [
    helm_release.argo_cd,
    kubernetes_secret.bot_secrets_dev,
    kubernetes_secret.bot_secrets_prod
  ]
}


resource "kubernetes_secret" "bot_secrets_dev" {
  metadata {
    name      = "bot-config-secret"
    namespace = "bot-dev"
  }

  data = {
    "bots_info.json" = jsonencode({
      "bots" : [
        {
          botTypeApi             = 1,
          token                  = var.prod_bot_token,
          website                = null,
          contactString          = null,
          onMessages             = var.prod_bot_onMessage,
          acceptedMessages       = true,
          SessionUserId          = null,
          userId                 = null,
          apiId                  = null,
          apiHash                = null,
          NumberCountry          = null,
          NumberNumber           = null,
          passwordToAuthenticate = null,
          method                 = null
        }
      ]
    })
    "dbconfig.json" = jsonencode({
      Database = var.dev_db_database,
      Host     = var.dev_db_host,
      Password = var.dev_db_password,
      Port     = 3306,
      User     = var.dev_db_user
    })
  }
}

resource "kubernetes_secret" "bot_secrets_prod" {
  metadata {
    name      = "bot-config-secret"
    namespace = "bot-prod"
  }

  data = {
    "bots_info.json" = jsonencode({
      "bots" : [
        {
          botTypeApi             = 1,
          token                  = var.prod_bot_token,
          website                = null,
          contactString          = null,
          onMessages             = var.prod_bot_onMessage,
          acceptedMessages       = true,
          SessionUserId          = null,
          userId                 = null,
          apiId                  = null,
          apiHash                = null,
          NumberCountry          = null,
          NumberNumber           = null,
          passwordToAuthenticate = null,
          method                 = null
        }
      ]
    })
    "dbconfig.json" = jsonencode({
      Database = var.prod_db_database,
      Host     = var.prod_db_host,
      Password = var.prod_db_password,
      Port     = 3306,
      User     = var.prod_db_user
    })
  }
}