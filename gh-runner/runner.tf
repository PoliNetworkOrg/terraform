resource "kubernetes_namespace" "bot-namespace" {
  metadata {
    name = var.runner_namespace
  }
}

resource "kubernetes_secret" "bot_secret" {
  metadata {
    name      = "runner-token"
    namespace = var.runner_namespace
  }

  data = {
    RUNNER_TOKEN = var.runner_token
  }
}
