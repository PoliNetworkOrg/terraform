resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.16.3"
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

module "cert_manager" {
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "2.4.2"

  cluster_issuer_server                  = "https://acme-staging-v02.api.letsencrypt.org/directory"
  cluster_issuer_email                   = "adminorg@polinetwork.org"
  cluster_issuer_name                    = "cert-manager-global"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
  solvers = [
    {
      http01 = {
        ingress = {
          class = "nginx"
        }
      }
    }
  ]
}

resource "kubernetes_ingress" "argocd_ingress" {
  metadata {
    name = "argocd-ingress"
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "argo-argocd-server"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts       = ["api.dev.polinetwork.org"]
      secret_name = "cert-manager-private-key"
    }
  }
}