resource "azurerm_linux_virtual_machine" "k3s" {
  #checkov:skip=CKV_AZURE_50:Break-glass recovery uses Azure Run Command, but no persistent VM extension is declared.
  name                            = "k3s01"
  computer_name                   = "k3s01"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.shared.name
  zone                            = var.availability_zone
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.k3s.id]
  provision_vm_agent              = true
  patch_assessment_mode           = "ImageDefault"
  patch_mode                      = "ImageDefault"
  secure_boot_enabled             = true
  vtpm_enabled                    = true
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(var.admin_ssh_public_key)
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.k3s["eso"].id,
      azurerm_user_assigned_identity.k3s["backend"].id,
      azurerm_user_assigned_identity.k3s["backup"].id,
    ]
  }

  os_disk {
    name                 = "disk-k3s01-os"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-13"
    sku       = "13-arm64"
    version   = "0.20260810.2566"
  }

  boot_diagnostics {}
}

resource "azurerm_managed_disk" "fast" {
  #checkov:skip=CKV_AZURE_93:Platform-managed encryption avoids a Key Vault dependency during disaster recovery.
  name                          = "disk-k3s-fast"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.shared.name
  zone                          = var.availability_zone
  storage_account_type          = "PremiumV2_LRS"
  create_option                 = "Empty"
  disk_size_gb                  = 64
  disk_iops_read_write          = 3000
  disk_mbps_read_write          = 125
  network_access_policy         = "DenyAll"
  public_network_access_enabled = false
  tags                          = merge(var.tags, { Mount = "/srv/fast" })

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_managed_disk" "standard" {
  #checkov:skip=CKV_AZURE_93:Platform-managed encryption avoids a Key Vault dependency during disaster recovery.
  name                          = "disk-k3s-standard"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.shared.name
  zone                          = var.availability_zone
  storage_account_type          = "StandardSSD_LRS"
  create_option                 = "Empty"
  disk_size_gb                  = 128
  network_access_policy         = "DenyAll"
  public_network_access_enabled = false
  tags                          = merge(var.tags, { Mount = "/srv/standard" })

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "fast" {
  managed_disk_id    = azurerm_managed_disk.fast.id
  virtual_machine_id = azurerm_linux_virtual_machine.k3s.id
  lun                = 0
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "standard" {
  managed_disk_id    = azurerm_managed_disk.standard.id
  virtual_machine_id = azurerm_linux_virtual_machine.k3s.id
  lun                = 1
  caching            = "ReadWrite"
}
