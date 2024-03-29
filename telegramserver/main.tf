resource "kubernetes_secret" "telegram_secret" {
  metadata {
    name      = "telegram-secrets"
    namespace = var.telegram_namespace
  }

  data = {
      NAME = ""
  }
}

resource "azurerm_managed_disk" "storage" {
  count                = var.persistent_storage ? 1 : 0
  name                 = "md-polinetwork-${random_uuid.volume.result}"
  location             = var.location
  resource_group_name  = var.persistent_storage_rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.persistent_storage_size_gi
}

resource "kubernetes_persistent_volume" "storage" {
  count = var.persistent_storage ? 1 : 0

  metadata {
    name = "${random_uuid.volume.result}-telegram-pv"
  }
  spec {
    capacity = {
      storage = "${var.persistent_storage_size_gi}Gi"
    }
    storage_class_name = "managed-csi"
    access_modes       = ["ReadWriteOnce"]
    persistent_volume_source {
      csi {
        driver        = "disk.csi.azure.com"
        volume_handle = azurerm_managed_disk.storage[0].id
      }
    }
  }

  depends_on = [
    azurerm_managed_disk.storage
  ]
}

resource "kubernetes_persistent_volume_claim" "storage_pvc" {
  count = var.persistent_storage ? 1 : 0
  metadata {
    name      = "telegram-pvc"
    namespace = var.telegram_namespace
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"
    resources {
      requests = {
        storage = "${var.persistent_storage_size_gi}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.storage[0].metadata[0].name
  }
}