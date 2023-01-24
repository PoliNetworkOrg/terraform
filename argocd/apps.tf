resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name              = "argo"
  repository        = "https://argoproj.github.io/argo-helm"
  chart             = "argo-cd"
  version           = "5.17.1"
  namespace         = var.namespace
  dependency_update = true

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    templatefile("${path.module}/values/argo_cd.tftpl", {
      clientId     = var.clientId
      clientSecret = var.clientSecret
      tenant       = var.tenant
    })
  ]
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = true

  values = var.applications

  depends_on = [
    helm_release.argo_cd
  ]
}

resource "kubernetes_manifest" "cert-argo-dex" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "argocd-dex-server-tls-cert"
      "namespace" = var.namespace
    }
    spec = {
      secretName = "argocd-dex-server-tls"
      dnsNames = [
        "argocd-dex-server",
        "argocd-dex-server.argo-cd.svc"
      ]
      issuerRef = {
        name = "ca-issuer"
        kind = "ClusterIssuer"
      }
    }
  }
}