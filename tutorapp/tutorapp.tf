resource "kubernetes_secret" "tutorapp_secret" {
  metadata {
    name      = "tutorapp-config-secret"
    namespace = var.tutorapp_namespace
  }

  data = {
    "webconfig.json" = jsonencode({
      Port          = 5000,
      WebLogLevel   = 3,
      AuthUsr       = var.secretAuthUser,
      AuthPsw       = var.secretAuthPassword,
      AllowedCors   = "*",
      Url           = "http://+",
      AzureSecret   = var.azureSecret,
      AzureClientId = var.azureClientId
    })
    "dbconfig.json" = jsonencode({
      Host     = var.db_host,
      Port     = 3306,
      User     = var.db_user,
      Password = var.db_password,
      DbName   = var.db_database
    })
    "botconfig.json" = jsonencode({
      BotToken             = var.bot_token,
      BotLogLevel          = 2,
      UserTimeOut          = 120000
      TutorLockHours       = 24,
      HasOnlineAuth        = false,
      AuthLink             = "www.example.com",
      MaxTutoringDuration  = 150,
      ShownTutorsInList    = 5,
      ShownTutorsInOFAList = 8
    })
  }
}