data "azurerm_subscription" "primary" {
}

# tfsec:ignore:azure-container-limit-authorized-ips
resource "azurerm_kubernetes_cluster" "k8s" {
  location                          = "westeurope"
  name                              = "aks-polinetwork"
  resource_group_name               = var.rg_name
  dns_prefix                        = "aks-polinetwork"
  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
    admin_group_object_ids = [
      "57561933-3873-400d-be92-cdad68d57c1f",
    ]
  }


  tags = {
    Environment = "Development"
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name         = "agentpool"
    vm_size      = "Standard_B2s"
    node_count   = 2
    os_disk_type = "Managed"
  }
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDO6AkesVkidSg3a+iTC4BmoyIQIyy+3vYrJDraB1I1Uymd5DhLeDbOJbs10SWVXknRRkAJ/l5/A3oqSyq5dOyLpwx9QurrQE/r1MnqxhDEH85OfnF89UxKyZ73YQZOmh6oN794iQFu+OCsg1nI0TSDB2t/TatbyoW9ePTsLHzVPGdagHL8sDX6SS2blkDlHEJw5rNBDceUnBvUEKQr9dNvGKs2naJC5wE2tm2U1HYXnsKi7nl6Z+CY9b/g56lfWWIG6nte37fBymYBaUOsjqDbdFKVCIjC0fxgwS6GhMhkZe7mfKVOHp6zo6VMHSM3L2U4MW8xdibbi1+wMt+GPwvraGb+PSnJSeeWYGHs7Y8am9BMEmBTJdrovpa4lir9j1bsv/fCHXB78rH9tNXYKb5wxVIQTWw8+/9Y1qDD4jxpXS1xd4NAkzGeJCLb+x+eNDNRiHUknxvGJf7Z4Yek/zEp1kRdCDl1JwNL8zsBkZfbglQuyIHhhMZwMYwKSTpdG+TydfEao7t6cvjvAGajlEPBYo/bVQHhxD10+qFzD6xJbAIvS2zxDca2KXsAkQA5dDAVQSCCrZpnBJUD4yVltZYcXhX5fyESoai0L++RSQ10mHOoxB8jk6kkmLY+1PuqFeNH38keUNezJz8wTH93SfBROUm64TbsS63wgkzQhyGDLw== Azure Cluster SSH Key"
    }
  }
  network_profile {
    network_policy    = "calico"
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "nginx-ingress"

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    templatefile("${path.module}/values/ingress.yaml.tftpl", {
    })
  ]

  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}


resource "helm_release" "cert-manager-controller" {
  name       = "jetstack"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.11.0"

  cleanup_on_fail  = true
  create_namespace = true

  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

module "cert_manager" {
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "2.4.2"

  cluster_issuer_server                  = "https://acme-v02.api.letsencrypt.org/directory" # staging: "https://acme-staging-v02.api.letsencrypt.org/directory"
  cluster_issuer_email                   = "adminorg@polinetwork.org"
  cluster_issuer_name                    = "letsencrypt-prod-issuer"
  cluster_issuer_private_key_secret_name = "letsencrypt-prod-issuer"
  create_namespace                       = false
  solvers = [
    {
      http01 = {
        ingress = {
          class = "nginx"
        }
      }
    }
  ]
  depends_on = [
    helm_release.cert-manager-controller
  ]
}


resource "kubernetes_manifest" "cert-argo-dex" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "ca-issuer"
    }
    spec = {
      ca = {
        secretName = "internal-ca"
      }
    }
  }
}


resource "kubernetes_cluster_role_binding" "adminorg" {
  metadata {
    name = "admin-global"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "adminorg@polinetwork.org"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "User"
    name      = "57561933-3873-400d-be92-cdad68d57c1f"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "azurerm_role_definition" "aks_reader" {
  name        = "aks_reader"
  scope       = data.azurerm_subscription.primary.id
  description = "This is a custom role created via Terraform"

  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/accessProfiles/listCredential/action",
      "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

resource "kubernetes_secret" "internal-ca" {
  metadata {
    name = "internal-ca"
  }

  data = {
    "tls.crt" = var.ca_tls_crt
    "tls.key" = var.ca_tls_key
  }
}
