resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.8.7"
  dependency_update = true
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = true
  force_update = true
  upgrade_install = true

  values = [
    templatefile("${path.module}/values/argo_cd.tftpl", {
      clientId     = var.clientId
      clientSecret = var.clientSecret
      tenant       = var.tenant
    })
  ]
}

#resource "kubernetes_manifest" "git_generator_applicationset" {
#  manifest = {
#    apiVersion = "argoproj.io/v1alpha1"
#    kind       = "ApplicationSet"
#    metadata = {
#      name      = "git-generator-app-set"
#      namespace = var.namespace
#    }
#    spec = {
#      generators = [
#        {
#          git = {
#            repoURL  = "https://github.com/PoliNetworkOrg/polinetwork-cd.git"
#            revision = "generator"
#            files = [
#              {
#                path = "**/config.json"
#              }
#            ]
#          }
#        }
#      ]
#      ignoreApplicationDifferences = [
#        {
#          jsonPointers = [
#            "/spec/source/kustomize/images"
#          ]
#        }
#      ]
#      template = {
#        metadata = {
#          name = "{{path.basename}}"
#          annotations = {
#            "argocd-image-updater.argoproj.io/write-back-method" = "argocd"
#            "argocd-image-updater.argoproj.io/argocd.force-update" = "true"
#            "argocd-image-updater.argoproj.io/image-list" = "{{image.image-list}}" 
#            "argocd-image-updater.argoproj.io/update-strategy" = "{{image.update-strategy}}"
#          }
#        }
#        spec = {
#          project = "default"
#          source = {
#            repoURL  = "https://github.com/PoliNetworkOrg/polinetwork-cd.git"
#            targetRevision = "generator"
#            path           = "{{path.basename}}/app"
#          }
#          destination = {
#            server    = "https://kubernetes.default.svc"
#            namespace = "{{path.basename}}"
#          }
#          syncPolicy = {
#            automated = {
#              prune    = true
#              selfHeal = true
#            }
#            syncOptions = [
#              "CreateNamespace=true"
#            ]
#          }
#        }
#      }
#    }
#  }
#
#  depends_on = [
#    helm_release.argo_cd
#  ]
#}

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
