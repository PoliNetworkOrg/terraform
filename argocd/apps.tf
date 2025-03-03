resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name              = "argo"
  repository        = "https://argoproj.github.io/argo-helm"
  chart             = "argo-cd"
  version           = "7.8.7"
  dependency_update = true
  namespace         = var.namespace

  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  upgrade_install  = true

  values = [
    templatefile("${path.module}/values/argo_cd.tftpl", {
      clientId     = var.clientId
      clientSecret = var.clientSecret
      tenant       = var.tenant
    })
  ]
}

resource "kubernetes_manifest" "argocd_git_generator_project" {
  manifest = yamldecode(templatefile("${path.module}/values/argocd-git-generator-project.yaml", {
    namespace = var.namespace
  }))

  depends_on = [
    helm_release.argo_cd
  ]
}

resource "kubernetes_manifest" "argocd_git_generator_applicationset" {
  manifest = yamldecode(templatefile("${path.module}/values/argocd-git-generator-appset.yaml", {
    namespace = var.namespace
  }))

  depends_on = [
    helm_release.argo_cd,
    kubernetes_manifest.argocd_git_generator_project
  ]
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = true

  values = var.applications

  depends_on = [
    helm_release.argo_cd
  ]
}
