resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "7.14.0"
  namespace  = var.namespace

  cleanup_on_fail  = true
  create_namespace = false

  values = [
    templatefile("${path.module}/values/dashboard.yaml.tftpl", {})
  ]

  depends_on = [
    kubernetes_namespace.namespace,
  ]
}

# RBAC Explanation:
# 
# With default authentication, users authenticate by providing their own Kubernetes tokens
# (ServiceAccount tokens, user tokens, etc.). The dashboard acts as a proxy - when a user
# makes a request through the dashboard UI, the dashboard forwards that request to the
# Kubernetes API server using the user's token. The dashboard containers themselves don't
# need special permissions because they're just proxying requests.
#
# Login to the UI is done using Cloudflare Tunnel + Cloudflare Access.
# We create a authorization token linked to this service account that expires in 104 years
# starting from today (31/10/2025). 
# If you are still there when this expires, you can generate a new one by running the 
# following command in the terminal (with kubectl configured):
#   kubectl create token admin-user -n kubernetes-dashboard
# Then change it in the header value "Authorization" found in
# the Cloudflare Rules section in our Cloudflare account.
resource "kubernetes_service_account" "admin_user" {
  metadata {
    name      = "admin-user"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "admin_user" {
  metadata {
    name = "admin-user-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = var.namespace
  }

  depends_on = [
    helm_release.kubernetes-dashboard
  ]
}

