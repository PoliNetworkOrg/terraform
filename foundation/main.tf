data "azurerm_resource_group" "target" {
  name = var.resource_group_name
}

data "azurerm_key_vault" "polinetwork" {
  name                = "kv-polinetwork"
  resource_group_name = data.azurerm_resource_group.target.name
}

data "azurerm_key_vault_secret" "vm_ssh_public_key" {
  name         = "compose-vm-ssh-public-key"
  key_vault_id = data.azurerm_key_vault.polinetwork.id
}

locals {
  prefix = "pn-compose-prod"
}

resource "azurerm_virtual_network" "main" {
  name                = "${local.prefix}-vnet"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target.name
  address_space       = ["10.42.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "host" {
  name                 = "host"
  resource_group_name  = data.azurerm_resource_group.target.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.42.1.0/24"]
}

resource "azurerm_network_security_group" "host" {
  name                = "${local.prefix}-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target.name
  tags                = var.tags

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "egress" {
  name                = "${local.prefix}-pip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "host" {
  name                           = "${local.prefix}-nic"
  location                       = var.location
  resource_group_name            = data.azurerm_resource_group.target.name
  accelerated_networking_enabled = true
  tags                           = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.host.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.egress.id
  }
}

resource "azurerm_network_interface_security_group_association" "host" {
  network_interface_id      = azurerm_network_interface.host.id
  network_security_group_id = azurerm_network_security_group.host.id
}

resource "azurerm_linux_virtual_machine" "host" {
  name                            = "${local.prefix}-vm"
  computer_name                   = "pn-compose-prod"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.target.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.host.id]
  custom_data                     = base64encode(file("${path.module}/templates/cloud-init.yaml"))
  provision_vm_agent              = true
  patch_assessment_mode           = "AutomaticByPlatform"
  patch_mode                      = "AutomaticByPlatform"
  secure_boot_enabled             = true
  vtpm_enabled                    = true
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(data.azurerm_key_vault_secret.vm_ssh_public_key.value)
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${local.prefix}-os"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 32
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-arm64"
    version   = "22.04.202608060"
  }

  boot_diagnostics {}

  depends_on = [azurerm_network_interface_security_group_association.host]
}

resource "azurerm_managed_disk" "state" {
  name                          = "${local.prefix}-state-p4"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.target.name
  storage_account_type          = "Premium_LRS"
  create_option                 = "Empty"
  disk_size_gb                  = 32
  network_access_policy         = "DenyAll"
  public_network_access_enabled = false
  tags                          = merge(var.tags, { DataClass = "state" })

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "state" {
  managed_disk_id    = azurerm_managed_disk.state.id
  virtual_machine_id = azurerm_linux_virtual_machine.host.id
  lun                = 0
  caching            = "None"
}

resource "azurerm_managed_disk" "applications" {
  name                          = "${local.prefix}-applications-e4"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.target.name
  storage_account_type          = "StandardSSD_LRS"
  create_option                 = "Empty"
  disk_size_gb                  = 32
  network_access_policy         = "DenyAll"
  public_network_access_enabled = false
  tags                          = merge(var.tags, { DataClass = "applications" })

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "applications" {
  managed_disk_id    = azurerm_managed_disk.applications.id
  virtual_machine_id = azurerm_linux_virtual_machine.host.id
  lun                = 1
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "prepare_data_disks" {
  name                       = "prepare-data-disks"
  virtual_machine_id         = azurerm_linux_virtual_machine.host.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = var.tags

  settings = jsonencode({
    commandToExecute = "echo '${base64encode(file("${path.module}/scripts/prepare-data-disks.sh"))}' | base64 -d | bash"
  })

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.state,
    azurerm_virtual_machine_data_disk_attachment.applications,
  ]
}

resource "azurerm_storage_account" "backup" {
  name                              = var.backup_storage_account_name
  resource_group_name               = data.azurerm_resource_group.target.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  account_kind                      = "StorageV2"
  access_tier                       = "Cool"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  public_network_access_enabled     = true
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true
  local_user_enabled                = false
  tags                              = merge(var.tags, { DataClass = "backup" })

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = [azurerm_public_ip.egress.ip_address]
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "backup" {
  name                  = "backup"
  storage_account_id    = azurerm_storage_account.backup.id
  container_access_type = "private"
}

resource "azurerm_storage_container_immutability_policy" "backup" {
  storage_container_resource_manager_id = azurerm_storage_container.backup.id
  immutability_period_in_days           = 14
  protected_append_writes_enabled       = true
}

resource "azurerm_storage_management_policy" "backup" {
  storage_account_id = azurerm_storage_account.backup.id

  rule {
    name    = "backup-retention"
    enabled = true

    filters {
      prefix_match = ["backup/"]
      blob_types   = ["blockBlob", "appendBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }

      snapshot {
        delete_after_days_since_creation_greater_than = 90
      }

      version {
        delete_after_days_since_creation = 90
      }
    }
  }
}

resource "azurerm_role_assignment" "vm_backup_writer" {
  scope                = azurerm_storage_container.backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.host.identity[0].principal_id
}

resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "polinetwork-monthly-ceiling"
  resource_group_id = data.azurerm_resource_group.target.id
  amount            = var.monthly_budget_amount_usd
  time_grain        = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = var.budget_contact_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }
}
