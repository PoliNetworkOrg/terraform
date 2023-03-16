resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "bot_secret" {
  metadata {
    name      = "aule-bot-secret"
    namespace = var.namespace
  }

  data = {
    TOKEN = var.aule_bot_token
  }
}