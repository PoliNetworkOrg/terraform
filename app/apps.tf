resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "app-secrets"
    namespace = var.app_namespace
  }

  data = {
    "dbconfig.json" = jsonencode({
      Database = var.db_database,
      Host     = var.db_host,
      Password = var.db_password,
      Port     = 3306,
      User     = var.db_user
    })
    "secrets.json" = jsonencode({
      Azure = var.app_secret_token,
    })
  }
}