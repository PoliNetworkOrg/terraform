resource "kubernetes_secret" "bot_secrets_dev" {
  metadata {
    name      = "bot-config-secret"
    namespace = "bot-dev"
  }

  data = {
    "bots_info.json" = jsonencode({
      "bots" : [
        {
          botTypeApi             = 1,
          token                  = var.dev_bot_token,
          website                = null,
          contactString          = null,
          onMessages             = var.dev_bot_onMessage,
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
      Database = var.dev_db_database,
      Host     = var.dev_db_host,
      Password = var.dev_db_password,
      Port     = 3306,
      User     = var.dev_db_user
    })
  }
}

resource "kubernetes_secret" "bot_secrets_prod" {
  metadata {
    name      = "bot-config-secret"
    namespace = "bot-prod"
  }

  data = {
    "bots_info.json" = jsonencode({
      "bots" : [
        {
          botTypeApi             = 1,
          token                  = var.prod_bot_token,
          website                = null,
          contactString          = null,
          onMessages             = var.prod_bot_onMessage,
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
      Database = var.prod_db_database,
      Host     = var.prod_db_host,
      Password = var.prod_db_password,
      Port     = 3306,
      User     = var.prod_db_user
    })
  }
}