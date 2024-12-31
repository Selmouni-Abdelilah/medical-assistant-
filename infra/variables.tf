# The region where the resources will be deployed
variable "region" {
  type    = string
  default = "westus"
}

# The name of the chat model to be used
variable "chat_model_name" {
  type    = string
  default = "gpt-4o"
}

# The version of the chat model to be used
variable "chat_model_version" {
  type    = string
  default = "2024-08-06"
}

# The type of scale to be used
variable "scale_type" {
  type        = string
  description = "values: GlobalStandard, Standard"
  default     = "GlobalStandard"
}

# The name of the cognitive account
variable "account_name" {
  type        = string
  description = "Cognitive Account Name"
}

# The SKU of the cognitive account
variable "sku_name" {
  type        = string
  description = "Cognitive Account SKU"
  default     = "S0"
}

# The custom subdomain name for the cognitive service
variable "custom_subdomain_name" {
  type        = string
  description = "Cognitive Service subdomain name"
}

# The name of the SQL server
variable "mssql_server_name" {
  type        = string
  default     = "medical-form-sql-server"
  description = "The name of SQL server"
}

# The name of the SQL database
variable "mssql_database_name" {
  type        = string
  default     = "medical-form-sql-database"
  description = "The name of SQL database"
}

# The username for accessing the database
variable "db_admin_login" {
  type        = string
  description = "The username for accessing the DB"
}

# The password for accessing the database
variable "db_admin_password" {
  type        = string
  sensitive   = true
  description = "The password for accessing the DB"
}
