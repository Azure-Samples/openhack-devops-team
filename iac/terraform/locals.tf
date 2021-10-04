resource "random_string" "uniquer" {
  length  = 5
  special = false
  number  = true
  lower   = false
  upper   = false
}

data "external" "my_ip" {
  program = ["/bin/bash", "${path.module}/myip.sh"]
}

locals {
  uniquer                                   = var.uniquer != null ? var.uniquer : "${random_string.uniquer.id}"
  resources_prefix                          = var.resources_prefix != null ? var.resources_prefix : "${local._default.name_prefix}${local.uniquer}"
  team_name                                 = local.resources_prefix
  location                                  = var.location
  resource_group_name                       = "${local.resources_prefix}rg"
  container_registry_name                   = "${local.resources_prefix}cr"
  mssql_server_name                         = "${local.resources_prefix}sql"
  mssql_server_administrator_login          = local._secrets.mssql_server_administrator_login
  mssql_server_administrator_login_password = local._secrets.mssql_server_administrator_login_password
  mssql_firewall_rule_myip                  = data.external.my_ip.result["my_ip"]
  mssql_database_name                       = "mydrivingDB"
  bing_maps_key                             = local._secrets.bing_maps_key
  app_service_plan_name                     = "${local.resources_prefix}plan"
  app_service_tripviewer_name               = "${local.resources_prefix}tripviewer"
  app_service_api-poi_name                  = "${local.resources_prefix}poi"
  app_service_api-trips_name                = "${local.resources_prefix}trips"
  app_service_api-user-java_name            = "${local.resources_prefix}userjava"
  app_service_api-userprofile_name          = "${local.resources_prefix}userprofile"
  container_group_simulator_name            = "${local.resources_prefix}simulator"
  base_image_tag                            = local._default.base_image_tag
}
