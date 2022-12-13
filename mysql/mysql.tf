resource "kubernetes_namespace" "mysql" {
  metadata {
    name = "mysql"
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_storage" {
  metadata {
    name      = "mysql-storage-claim"
    namespace = "mysql"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"
    resources {
      requests = {
        storage = "100Gi"
      }
    }
    volume_name = var.persistent_volume_name
  }
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name      = "mysql"
    namespace = "mysql"
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port = 3306
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_secret" "mysql_admin" {
  metadata {
    name      = "mysql-secret"
    namespace = "mysql"
  }

  data = {
    MYSQL_ROOT_PASSWORD = var.mysql_root_password
  }
}

resource "kubernetes_secret" "initdb" {
  metadata {
    name      = "initdb"
    namespace = "mysql"
  }

  data = {
    "initdb.sql" = templatefile("${path.module}/values/initdb.sql.tftpl", {
      db_dev_user      = var.dev_db_user
      db_prod_user     = var.prod_db_user
      db_dev_password  = var.dev_db_password
      db_prod_password = var.prod_db_password
    })
  }
}