resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "azurerm_managed_disk" "storage" {
  name                 = "md-polinetwork-postgres"
  location             = var.location
  resource_group_name  = var.rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "32"
  tier                 = "P4"
}

resource "kubernetes_persistent_volume" "storageaks" {
  metadata {
    name = "postgres-persistent-volume"
  }
  spec {
    capacity = {
      storage = "32Gi"
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

resource "kubernetes_persistent_volume_claim" "postgres_storage" {
  metadata {
    name      = "postgres-pvc"
    namespace = "postgres"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"
    resources {
      requests = {
        storage = "32Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.storageaks.metadata[0].name
  }
}
