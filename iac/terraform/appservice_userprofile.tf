############################################
## APP SERVICE - API-USERPROFILE          ##
############################################

resource "azurerm_app_service" "app_service_api-userprofile" {
  depends_on = [
    null_resource.db_datainit,
    null_resource.docker_api-userprofile
  ]
  name                = local.app_service_api-userprofile_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "SQL_USER"                        = local.mssql_server_administrator_login
    "SQL_PASSWORD"                    = local.mssql_server_administrator_login_password
    "SQL_SERVER"                      = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"                      = local.mssql_database_name
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on         = true
    http2_enabled     = true
    health_check_path = "/api/healthcheck/user"
    ftps_state        = "Disabled"
    # acr_use_managed_identity_credentials = true
    linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-userprofile:${local.base_image_tag}"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 50
      }
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      app_settings["DOCKER_REGISTRY_SERVER_URL"],
      app_settings["DOCKER_REGISTRY_SERVER_USERNAME"],
      app_settings["DOCKER_REGISTRY_SERVER_PASSWORD"],
      app_settings["SQL_PASSWORD"],
      site_config[0].linux_fx_version
    ]
  }
}

# resource "azurerm_key_vault_access_policy" "key_vault_access_policy_api-userprofile" {
#   key_vault_id = azurerm_key_vault.key_vault.id
#   tenant_id    = azurerm_app_service.app_service_api-userprofile.identity[0].tenant_id
#   object_id    = azurerm_app_service.app_service_api-userprofile.identity[0].principal_id

#   secret_permissions = [
#     "Get"
#   ]
# }

# resource "azurerm_role_assignment" "cr_role_assignment_api-userprofile" {
#   scope                = azurerm_container_registry.container_registry.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_app_service.app_service_api-userprofile.identity[0].principal_id
# }

resource "azurerm_app_service_slot" "app_service_api-userprofile_staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.app_service_api-userprofile.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "SQL_USER"                        = local.mssql_server_administrator_login
    "SQL_PASSWORD"                    = local.mssql_server_administrator_login_password
    "SQL_SERVER"                      = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"                      = local.mssql_database_name
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on         = true
    http2_enabled     = true
    health_check_path = "/api/healthcheck/user"
    ftps_state        = "Disabled"
    # acr_use_managed_identity_credentials = true
    linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-userprofile:${local.base_image_tag}"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 50
      }
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      app_settings["DOCKER_REGISTRY_SERVER_URL"],
      app_settings["DOCKER_REGISTRY_SERVER_USERNAME"],
      app_settings["DOCKER_REGISTRY_SERVER_PASSWORD"],
      app_settings["SQL_PASSWORD"],
      site_config[0].linux_fx_version
    ]
  }
}

# resource "azurerm_key_vault_access_policy" "key_vault_access_policy_api-userprofile_staging" {
#   key_vault_id = azurerm_key_vault.key_vault.id
#   tenant_id    = azurerm_app_service_slot.app_service_api-userprofile_staging.identity[0].tenant_id
#   object_id    = azurerm_app_service_slot.app_service_api-userprofile_staging.identity[0].principal_id

#   secret_permissions = [
#     "Get"
#   ]
# }

# resource "azurerm_role_assignment" "cr_role_assignment_api-userprofile_staging" {
#   scope                = azurerm_container_registry.container_registry.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_app_service_slot.app_service_api-userprofile_staging.identity[0].principal_id
# }