resource "azurerm_resource_group" "rg" {
  name     = "rg-polinetwork"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

locals {
  backup_allowed_subnet_ids = [
    "${azurerm_resource_group.rg.id}/providers/Microsoft.Network/virtualNetworks/vnet-k3s/subnets/snet-k3s",
  ]
}

moved {
  from = module.foundation.azurerm_storage_account.backup
  to   = module.shared.azurerm_storage_account.backup
}

moved {
  from = module.foundation.azurerm_storage_container.backup
  to   = module.shared.azurerm_storage_container.backup
}

moved {
  from = module.foundation.azurerm_storage_container.zerobyte
  to   = module.shared.azurerm_storage_container.zerobyte
}

moved {
  from = module.foundation.azurerm_storage_container_immutability_policy.backup
  to   = module.shared.azurerm_storage_container_immutability_policy.backup
}

moved {
  from = module.foundation.azurerm_storage_management_policy.backup
  to   = module.shared.azurerm_storage_management_policy.backup
}

moved {
  from = module.foundation.azurerm_consumption_budget_resource_group.monthly
  to   = module.shared.azurerm_consumption_budget_resource_group.monthly
}

moved {
  from = module.foundation.azurerm_consumption_budget_resource_group.annual
  to   = module.shared.azurerm_consumption_budget_resource_group.annual
}

module "keyvault" {
  source = "../../modules/keyvault/"

  name = "kv-polinetwork"

  location  = azurerm_resource_group.rg.location
  rg_name   = azurerm_resource_group.rg.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  allowed_ips = []
}

module "storageaccount" {
  source = "../../modules/storage"

  location = azurerm_resource_group.rg.location
  rg_name  = azurerm_resource_group.rg.name
}

module "shared" {
  source = "../../modules/shared"

  location            = azurerm_resource_group.rg.location
  resource_group_id   = azurerm_resource_group.rg.id
  resource_group_name = azurerm_resource_group.rg.name
  allowed_subnet_ids  = local.backup_allowed_subnet_ids
}

# AKS decommission (production runs on K3s since 2026-10-09). Only the cluster
# and its node pool are destroyed. Everything that lived inside the cluster
# disappears with it, so Terraform forgets it instead of calling the cluster.
# The two database disks are forgotten too and kept for the 14-day retention
# window of the migration plan; delete them manually after 2026-10-23.
removed {
  from = module.argo-cd
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.cloudflare
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.app_dev
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.kubernetes-dashboard
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.longhorn
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.mariadb
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.postgres
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.aks.kubernetes_cluster_role_binding.adminorg
  lifecycle {
    destroy = false
  }
}

# Azure refuses to delete a role definition while assignments reference it;
# the assignments on the deleted cluster are cleaned up manually first.
removed {
  from = module.aks.azurerm_role_definition.aks_reader
  lifecycle {
    destroy = false
  }
}
