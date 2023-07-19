resource "kubernetes_namespace" "logs" {
  metadata {
    name = var.logging-namespace
  }
}


resource "random_uuid" "volume" {
}

resource "azurerm_managed_disk" "storage" {
  count                = var.persistent_storage ? 1 : 0
  name                 = "logging-${random_uuid.volume.result}"
  location             = var.persistent_storage_location
  resource_group_name  = var.persistent_storage_rg_name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.persistent_storage_size_gi
}

resource "kubernetes_persistent_volume" "storage" {
  count = var.persistent_storage ? 1 : 0

  metadata {
    name = "${random_uuid.volume.result}-logging-pv"
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
    name      = "logging-pvc"
    namespace = var.logging-namespace
    labels = {
      "app" = "logging"
    }
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

resource "kubernetes_secret" "openobserve-secret" {
  metadata {
    name      = "openobserve-secret"
    namespace = var.logging-namespace
  }

  data = {
    ZO_ROOT_USER_PASSWORD = var.openobserve_password
  }

  type = "Opaque"
}


resource "helm_release" "fluentbit" {
  name       = "fluent"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = var.logging-namespace
  version    = "0.34.1"

  create_namespace = false
  cleanup_on_fail  = true

  values = [
    templatefile("${path.module}/values/fluentbit.yaml.tftpl", {
      openobserve_password = var.openobserve_password
    })
  ]
}
