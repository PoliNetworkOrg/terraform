resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "app-secrets"
    namespace = var.app_namespace
  }

  data = {
    "dbconfig.json" = jsonencode({
      DatabaseName = var.db_database,
      Host         = var.db_host,
      Password     = var.db_password,
      Port         = 3306,
      User         = var.db_user
    })
    "secrets.json" = jsonencode({
      Azure = var.app_secret_token,
    })
  }
}

resource "kubernetes_role" "app_dev" {
  metadata {
    name = "AppDev"
    labels = {
      group = "AppDev"
    }
    namespace = var.app_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding" "app_dev" {
  metadata {
    name      = "app-dev-bind"
    namespace = var.app_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "AppDev"
  }
  subject {
    kind      = "Group"
    name      = "eef863f8-df90-413f-ac21-f0ef86e0d9d3"
    api_group = "rbac.authorization.k8s.io"
  }
}