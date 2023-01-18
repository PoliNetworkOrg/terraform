# variable "dev_db_bot_database" {
#   type     = string
#   nullable = false
# }

# variable "deb_db_bot_password" {
#   type     = string
#   nullable = false
# }

# variable "deb_db_bot_user" {
#   type     = string
#   nullable = false
# }

# variable "dev_db_bot_password" {
#   type     = string
#   nullable = false
# }

# variable "dev_db_bot_user" {
#   type     = string
#   nullable = false
# }

# variable "prod_db_bot_database" {
#   type     = string
#   nullable = false
# }

# variable "prod_db_bot_password" {
#   type     = string
#   nullable = false
# }

# variable "prod_db_bot_user" {
#   type     = string
#   nullable = false
# }

# variable "dev_db_app_database" {
#   type     = string
#   nullable = false
# }

# variable "dev_db_app_password" {
#   type     = string
#   nullable = false
# }

# variable "dev_db_app_user" {
#   type     = string
#   nullable = false
# }

# variable "mat_db_bot_database" {
#   type     = string
#   nullable = false
# }

# variable "mat_db_bot_password" {
#   type     = string
#   nullable = false
# }

# variable "mat_db_bot_user" {
#   type     = string
#   nullable = false
# }

variable "db_config" {
  type = list(object({
    user     = string
    password = string
    database = string
  }))
  nullable = false
}

variable "mariadb_internal_ip" {
  type     = string
  nullable = false
}

variable "mariadb_root_password" {
  type     = string
  nullable = false
}

variable "location" {
  type     = string
  nullable = false
}

variable "rg_name" {
  type     = string
  nullable = false
}