resource "random_uuid" "volume" {
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "prometheus-stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "46.8.0"
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = false

  values = [
    templatefile("${path.module}/values/grafana.yaml.tftpl", {
      grafana_admin_password            = var.grafana_admin_password
      cluster_monitoring_telegram_token = var.cluster_monitoring_telegram_token
      cluster_monitoring_app_password   = var.cluster_monitoring_app_password
    })
  ]

  depends_on = [
    kubernetes_namespace.namespace
    # kubernetes_persistent_volume_claim.storage_pvc
  ]
}

resource "azurerm_managed_disk" "storage" {
  count                = var.persistent_storage ? 1 : 0
  name                 = "md-polinetwork-${random_uuid.volume.result}"
  location             = var.persistent_storage_location
  resource_group_name  = var.persistent_storage_rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.persistent_storage_size_gi
}

# resource "kubernetes_persistent_volume" "storage" {
#   count = var.persistent_storage ? 1 : 0

#   metadata {
#     name = "${random_uuid.volume.result}-grafana-pv"
#   }
#   spec {
#     capacity = {
#       storage = "${var.persistent_storage_size_gi}Gi"
#     }
#     storage_class_name = "managed-csi"
#     access_modes       = ["ReadWriteOnce"]
#     persistent_volume_source {
#       csi {
#         driver        = "disk.csi.azure.com"
#         volume_handle = azurerm_managed_disk.storage[0].id
#       }
#     }
#   }

#   depends_on = [
#     azurerm_managed_disk.storage
#   ]
# }

# resource "kubernetes_persistent_volume_claim" "storage_pvc" {
#   count = var.persistent_storage ? 1 : 0
#   metadata {
#     name      = "grafana-pvc"
#     namespace = var.namespace
#   }
#   spec {
#     access_modes       = ["ReadWriteOnce"]
#     storage_class_name = "managed-csi"
#     resources {
#       requests = {
#         storage = "${var.persistent_storage_size_gi}Gi"
#       }
#     }
#     volume_name = kubernetes_persistent_volume.storage[0].metadata[0].name
#   }
# }