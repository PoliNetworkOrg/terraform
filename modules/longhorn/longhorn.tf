locals {
  namespace = "longhorn-system"
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.8.1"

  namespace = local.namespace

  values = [yamlencode({
    persistence = {
      recurringJobSelector = {
        enable  = true
        jobList = jsonencode([{ name = "default", isGroup = true }])
      }
    }
  })]

  # Chart 1.8.1 declares backupTargetName but omits it from its template.
  postrender {
    binary_path = "${path.module}/scripts/longhorn-postrender.sh"
  }

  depends_on = [kubernetes_daemon_set_v1.multipath_exclusion]

  set {
    name  = "defaultSettings.defaultReplicaCount"
    value = "1"
  }

  # StorageClass parameters override the global replica default.
  set {
    name  = "persistence.defaultClassReplicaCount"
    value = "1"
  }

  set {
    name  = "persistence.reclaimPolicy"
    value = "Retain"
  }

  set {
    name  = "defaultSettings.guaranteedInstanceManagerCPU"
    value = "6"
  }
}
