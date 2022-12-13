variable "persistent_volume_name" {
  type     = string
  nullable = false
}

variable "dev_db_database" {
  type     = string
  nullable = false
}


variable "dev_db_password" {
  type     = string
  nullable = false
}

variable "dev_db_user" {
  type     = string
  nullable = false
}

variable "prod_db_database" {
  type     = string
  nullable = false
}

variable "prod_db_password" {
  type     = string
  nullable = false
}

variable "prod_db_user" {
  type     = string
  nullable = false
}

variable "mysql_root_password" {
  type     = string
  nullable = false
}