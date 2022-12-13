resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "bot-dev" {
  metadata {
    name = "bot-dev"
  }
}

resource "kubernetes_namespace" "bot-prod" {
  metadata {
    name = "bot-prod"
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.5.7"
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    templatefile("${path.module}/values/argo_cd.tftpl", {
      # repo_credentials  = var.repo_credentials
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
