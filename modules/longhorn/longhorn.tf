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

  set {
    name  = "defaultSettings.defaultReplicaCount"
    value = "1"
  }

  set {
    name  = "defaultSettings.guaranteedInstanceManagerCPU"
    value = "6"
  }
}
