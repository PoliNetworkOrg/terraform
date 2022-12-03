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
    kubernetes_secret.bot_secrets
  ]
}


resource "kubernetes_secret" "bot_secrets" {
  metadata {
    name      = "bot-config-secret"
    namespace = "bot"
  }

  data = {
    "config.json" = jsonencode({
      "bots" : [
        {
          botTypeApi             = 1,
          token                  = var.bot_token,
          website                = null,
          contactString          = null,
          onMessages             = var.bot_onMessage,
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
    "database.json" = jsonencode({
      Database = "polinetwork_test",
      Host     = var.db_host,
      Password = var.db_password,
      Port     = 3306,
      User     = var.db_user
    })
  }
}