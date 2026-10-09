resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "37.3.0"

  namespace = var.namespace
}
