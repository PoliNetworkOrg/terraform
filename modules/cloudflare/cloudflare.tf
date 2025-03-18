resource "kubernetes_namespace" "cloudflare" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cloudflared" {
  name       = "cloudflared"
  repository = "https://cloudflare.github.io/helm-charts"
  chart      = "cloudflare-tunnel-remote"
  version    = "0.1.2"

  namespace = var.namespace

  set {
    name  = "cloudflare.tunnel_token"
    value = var.tunnel_token
  }
}
