resource "azurerm_resource_group" "rg" {
  name     = "rg-polinetwork"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvalue" {
  name                        = "kv-polinetwork"
  location                    = "West Europe"
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [local.elia-ip]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Get", "List", "Update", "Create", "Import", "Delete",
      "Recover", "Backup", "Restore"
    ]

    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup",
      "Restore"
    ]

    certificate_permissions = ["Get", "List", "Update", "Create", "Import",
      "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers",
      "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
    ]
  }
}

data "azurerm_key_vault_secret" "dev_mod_bot_token" {
  name         = "dev-mod-bot-token"
  key_vault_id = azurerm_key_vault.keyvalue.id
}

data "azurerm_key_vault_secret" "prod_mod_bot_token" {
  name         = "prod-mod-bot-token"
  key_vault_id = azurerm_key_vault.keyvalue.id
}

data "azurerm_key_vault_secret" "dev_db_host" {
  name         = "dev-db-host"
  key_vault_id = azurerm_key_vault.keyvalue.id
}

data "azurerm_key_vault_secret" "dev_db_password" {
  name         = "dev-db-password"
  key_vault_id = azurerm_key_vault.keyvalue.id
}

data "azurerm_key_vault_secret" "dev_db_user" {
  name         = "dev-db-user"
  key_vault_id = azurerm_key_vault.keyvalue.id
}

data "azurerm_key_vault_secret" "admin_db_password" {
  name         = "admin-db-password"
  key_vault_id = azurerm_key_vault.keyvalue.id
}


data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  my_ip   = "${chomp(data.http.myip.response_body)}/32"
  elia-ip = "185.178.95.235/32"
}


resource "azurerm_kubernetes_cluster" "k8s" {
  location                          = "westeurope"
  name                              = "aks-polinetwork"
  resource_group_name               = azurerm_resource_group.rg.name
  dns_prefix                        = "aks-polinetwork"
  api_server_authorized_ip_ranges   = [local.elia-ip]
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
  name                 = "acctestmd1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1000"

  tags = {
    environment = "staging"
  }
}

resource "kubernetes_persistent_volume" "storageaks" {
  metadata {
    name = "storage"
  }
  spec {
    capacity = {
      storage = "1000Gi"
    }
    access_modes = ["ReadWrite"]
    persistent_volume_source {
      azure_disk {
        caching_mode  = "None"
        data_disk_uri = azurerm_managed_disk.storage.id
        disk_name     = "storage"
        kind          = "Managed"
      }
    }
  }
}