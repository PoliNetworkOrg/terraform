resource "random_uuid" "volume" {
}

resource "kubernetes_namespace" "bot-namespace" {
  metadata {
    name = var.bot_namespace
  }
}

resource "kubernetes_secret" "bot_secret" {
  metadata {
    name      = "bot-config-secret"
    namespace = var.bot_namespace
  }

  data = {
    "bots_info.json" = jsonencode({
      "bots" : [
        {
          botTypeApi             = 1,
          token                  = var.bot_token,
          website                = null,
          contactString          = null,
          onMessages             = var.bot_onMessage,
          acceptedMessages       = true,
          SessionUserId          = null,
          userId                 = null,
          apiId                  = null,
          apiHash                = null,
          NumberCountry          = null,
          NumberNumber           = null,
          passwordToAuthenticate = null,
          method                 = null
        }
      ]
    })
    "dbconfig.json" = jsonencode({
      Database = var.db_database,
      Host     = var.db_host,
      Password = var.db_password,
      Port     = 3306,
      User     = var.db_user
    })
  }
}

resource "azurerm_managed_disk" "storage" {
  count                = var.persistent_storage ? 1 : 0
  name                 = "md-polinetwork-${random_uuid.volume.result}"
  location             = var.persistent_storage_location
  resource_group_name  = var.persistent_storage_rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.persistent_storage_size_gi
}

resource "kubernetes_persistent_volume" "storage" {
  count = var.persistent_storage ? 1 : 0

  metadata {
    name = "${random_uuid.volume.result}-bot-pv"
  }
  spec {
    capacity = {
      storage = "${var.persistent_storage_size_gi}Gi"
    }
    storage_class_name = "managed-csi"
    access_modes       = ["ReadWriteOnce"]
    persistent_volume_source {
      csi {
        driver        = "disk.csi.azure.com"
        volume_handle = azurerm_managed_disk.storage[0].id
      }
    }
  }

  depends_on = [
    azurerm_managed_disk.storage
  ]
}

resource "kubernetes_persistent_volume_claim" "storage_pvc" {
  count = var.persistent_storage ? 1 : 0
  metadata {
    name      = "bot-pvc"
    namespace = var.bot_namespace
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"
    resources {
      requests = {
        storage = "${var.persistent_storage_size_gi}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.storage[0].metadata[0].name
  }
}

resource "kubernetes_secret" "git_config" {
  count = var.git_config ? 1 : 0
  metadata {
    name      = "git-config"
    namespace = var.bot_namespace
  }

  data = {
    "git_info.json" = jsonencode({
      user        = var.git_user,
      email       = var.git_email,
      password    = var.git_password,
      data_repo   = var.git_data_repo,
      remote_repo = var.git_remote_repo,
      path        = var.git_path
    })
  }
}