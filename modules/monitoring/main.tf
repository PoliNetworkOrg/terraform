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
    kubernetes_namespace.namespace,
    kubernetes_persistent_volume_claim.storage_pvc
  ]
}
