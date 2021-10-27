variable "location" {
  description = ""
  type        = string
}
variable "uniquer" {
  description = ""
  type        = string
  default     = null
}
variable "resources_prefix" {
  description = ""
  type        = string
  default     = null
}

variable "docker_registry_server_url" {
  description = ""
  type        = string
  default     = null
}

variable "docker_registry_server_username" {
  description = ""
  type        = string
  default     = null
}

variable "docker_registry_server_password" {
  description = ""
  type        = string
  default     = null
  sensitive   = true
}

variable "mssql_server_administrator_login" {
  description = ""
  type        = string
  default     = null
}

variable "mssql_server_administrator_login_password" {
  description = ""
  type        = string
  default     = null
  sensitive   = true
}