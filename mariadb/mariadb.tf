resource "kubernetes_namespace" "mariadb" {
  metadata {
    name = "mariadb"
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
    type       = "ClusterIP"
    cluster_ip = var.mariadb_internal_ip
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
      db_config = var.db_config
    })
  }
}

resource "kubernetes_config_map" "initdb" {
  metadata {
    name      = "scripts"
    namespace = "mariadb"
  }

  data = {
    "startup.sh" = templatefile("${path.module}/script/startup.sh.tftpl", {
      db_admin_password = var.mariadb_root_password
    })
  }
}

resource "azurerm_managed_disk" "storage" {
  name                 = "md-polinetwork"
  location             = var.location
  resource_group_name  = var.rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"
}

resource "kubernetes_persistent_volume" "storageaks" {
  metadata {
    name = "mariadb-persistent-volume"
  }
  spec {
    capacity = {
      storage = "100Gi"
    }
    storage_class_name = "managed-csi"
    access_modes       = ["ReadWriteOnce"]
    persistent_volume_source {
      csi {
        driver        = "disk.csi.azure.com"
        volume_handle = azurerm_managed_disk.storage.id
      }
    }
  }

  depends_on = [
    azurerm_managed_disk.storage
  ]
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
    volume_name = kubernetes_persistent_volume.storageaks.metadata[0].name
  }
}