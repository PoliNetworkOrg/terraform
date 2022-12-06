resource "kubernetes_service" "argocd" {
  metadata {
    name = "ingress-service"
  }
  spec {
    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress" "ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "ingress-polinetwork"
    annotations = {
      "kubernetes.io/ingress.class" = "ingress-polinetwork"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.argocd.metadata[0].name
            service_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_class" "argocd" {
  metadata {
    name = "argocd"
  }

  spec {
    controller = "argocd.com/ingress-controller"
    parameters {
      api_group = "k8s.argocd.com"
      kind      = "IngressParameters"
      name      = "external-lb"
    }
  }
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
  value = kubernetes_ingress.ingress.status[0].load_balancer[0].ingress[0].hostname
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value = kubernetes_ingress.ingress.status[0].load_balancer[0].ingress[0].ip
}