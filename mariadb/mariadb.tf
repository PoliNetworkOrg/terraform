resource "kubernetes_namespace" "mariadb" {
  metadata {
    name = "mariadb"
  }
}

resource "kubernetes_persistent_volume_claim" "mariadb_storage" {
  metadata {
    name      = "mariadb-storage-claim"
    namespace = "mariadb"
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

resource "kubernetes_service" "mariadb_service" {
  metadata {
    name      = "mariadb"
    namespace = "mariadb"
  }
  spec {
    selector = {
      app = "mariadb"
    }
    port {
      port = 3306
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_secret" "mariadb_admin" {
  metadata {
    name      = "mariadb-secret"
    namespace = "mariadb"
  }

  data = {
    MARIADB_ROOT_PASSWORD = var.mariadb_root_password
  }
}

resource "kubernetes_secret" "initdb" {
  metadata {
    name      = "initdb"
    namespace = "mariadb"
  }

  data = {
    "initdb.sql" = templatefile("${path.module}/values/initdb.sql.tftpl", {
      db_dev_user      = var.dev_db_user
      db_prod_user     = var.prod_db_user
      db_dev_password  = var.dev_db_password
      db_prod_password = var.prod_db_password
      db_dev_database  = var.dev_db_database
      db_prod_database = var.prod_db_database
    })
  }
}
