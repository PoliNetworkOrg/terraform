resource "azurerm_resource_group" "rg" {
  name     = "rg-polinetwork"
  location = "West Europe"
}


resource "azurerm_kubernetes_cluster" "k8s" {
  location            = "westeurope"
  name                = "aks-polinetwork"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-polinetwork"
  api_server_authorized_ip_ranges = [
    "185.178.95.235/32"
  ]
  role_based_access_control_enabled = true

  tags = {
    Environment = "Development"
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "standard_a2_v2"
    node_count = 1
  }
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETs+7W2exMT/Ekos8bagl/raY0YGiQLK7l7Q9dpBLyL Microsoft AKS SSH Key"
    }
  }
  network_profile {
    network_policy    = "calico"
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
