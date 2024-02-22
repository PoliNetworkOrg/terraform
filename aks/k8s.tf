data "azurerm_subscription" "primary" {
}

# tfsec:ignore:azure-container-limit-authorized-ips
resource "azurerm_kubernetes_cluster" "k8s" {
  location                          = "westeurope"
  name                              = "aks-polinetwork"
  resource_group_name               = var.rg_name
  dns_prefix                        = "aks-polinetwork"
  role_based_access_control_enabled = true
  http_application_routing_enabled  = true

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
    name                 = "userpool"
    vm_size              = "Standard_B2ms"
    os_disk_type         = "Managed"
    os_disk_size_gb      = 30
    orchestrator_version = var.kubernetes_orchestrator_version
    enable_auto_scaling  = true
    max_count            = 1
    min_count            = 1
    node_count           = 1
    temporary_name_for_rotation = "temp" 
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
  kubernetes_version = var.kubernetes_orchestrator_version
}

resource "azurerm_kubernetes_cluster_node_pool" "systempool" {
  for_each              = { for i, v in var.additional_node_pools : i => v }
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  mode                  = each.value.mode == null ? "User" : each.value.mode
  tags                  = each.value.tags
  orchestrator_version  = var.kubernetes_orchestrator_version
  enable_auto_scaling   = each.value.enable_auto_scaling
  max_count             = each.value.max_count
  min_count             = each.value.min_count
}

# resource "kubernetes_namespace" "nginx" {
#   metadata {
#     name = "nginx-ingress"
#   }
# }

# resource "helm_release" "ingress-nginx" {
#   name       = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "nginx-ingress"

#   cleanup_on_fail  = true
#   create_namespace = true

#   values = [
#     templatefile("${path.module}/values/ingress.yaml.tftpl", {
#     })
#   ]

#   depends_on = [
#     azurerm_kubernetes_cluster.k8s
#   ]
# }


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