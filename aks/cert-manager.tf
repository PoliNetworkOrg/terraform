resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.cert_namespace
  version    = "1.12.1"

  create_namespace = true
  cleanup_on_fail  = true

  values = [
    templatefile("${path.module}/values/cert-manager.yaml.tftpl", {
    })
  ]
}

resource "kubernetes_manifest" "cluster-issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod-issuer"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "adminorg@polinetwork.org"

        privateKeySecretRef = {
          name = "cert-manager-key"
        }

        solvers = [
          {
            http01 = {
              ingress = {
                class = "addon-http-application-routing",
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert-manager
  ]
}