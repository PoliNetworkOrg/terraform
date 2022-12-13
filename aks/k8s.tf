resource "azurerm_kubernetes_cluster" "k8s" {
  location                          = "westeurope"
  name                              = "aks-polinetwork"
  resource_group_name               = var.rg_name
  dns_prefix                        = "aks-polinetwork"
  api_server_authorized_ip_ranges   = var.allowed_ips
  role_based_access_control_enabled = true


  tags = {
    Environment = "Development"
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name         = "agentpool"
    vm_size      = "standard_a2_v2"
    node_count   = 1
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

resource "azurerm_managed_disk" "storage" {
  name                 = "mg-polinetwork"
  location             = var.location
  resource_group_name  = var.rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1000"

  tags = {
    environment = "staging"
  }
}

resource "kubernetes_persistent_volume" "storageaks" {
  metadata {
    name = "mysql-persistent-volume"
  }
  spec {
    capacity = {
      storage = "1000Gi"
    }
    storage_class_name = "managed-csi"
    access_modes       = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
      # azure_disk {
      #   caching_mode  = "None"
      #   data_disk_uri = azurerm_managed_disk.storage.id
      #   disk_name     = "storage"
      #   kind          = "Managed"
      # }
    }
  }
}
