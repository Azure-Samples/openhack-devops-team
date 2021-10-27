############################################
## APP SERVICE - API-POI                  ##
############################################

resource "azurerm_app_service" "app_service_api-poi" {
  depends_on = [
    null_resource.db_datainit,
    null_resource.docker_api-poi
  ]
  name                = local.app_service_api-poi_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "SQL_USER"     = local.mssql_server_administrator_login
    "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    # "SQL_PASSWORD"                    = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.key_vault.name};SecretName=${azurerm_key_vault_secret.key_vault_secret_sqlpassword.name})"
    "SQL_SERVER"                            = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"                            = local.mssql_database_name
    "WEBSITES_PORT"                         = "8080"
    "DOCKER_REGISTRY_SERVER_URL"            = local.docker_registry_server_url
    "DOCKER_REGISTRY_SERVER_USERNAME"       = local.docker_registry_server_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"       = local.docker_registry_server_password
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.application_insights.connection_string
  }

  site_config {
    always_on         = true
    http2_enabled     = true
    ftps_state        = "Disabled"
    health_check_path = "/api/healthcheck/poi"
    # acr_use_managed_identity_credentials = true
    linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-poi:${local.base_image_tag}"
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
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      site_config[0].linux_fx_version
    ]
  }
}

# resource "azurerm_key_vault_access_policy" "key_vault_access_policy_api-poi" {
#   key_vault_id = azurerm_key_vault.key_vault.id
#   tenant_id    = azurerm_app_service.app_service_api-poi.identity[0].tenant_id
#   object_id    = azurerm_app_service.app_service_api-poi.identity[0].principal_id

#   secret_permissions = [
#     "Get"
#   ]
# }

# resource "azurerm_role_assignment" "cr_role_assignment_api-poi" {
#   scope                = azurerm_container_registry.container_registry.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_app_service.app_service_api-poi.identity[0].principal_id
# }

resource "azurerm_app_service_slot" "app_service_api-poi_staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.app_service_api-poi.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "SQL_USER"                              = local.mssql_server_administrator_login
    "SQL_PASSWORD"                          = local.mssql_server_administrator_login_password
    "SQL_SERVER"                            = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"                            = local.mssql_database_name
    "WEBSITES_PORT"                         = "8080"
    "DOCKER_REGISTRY_SERVER_URL"            = local.docker_registry_server_url
    "DOCKER_REGISTRY_SERVER_USERNAME"       = local.docker_registry_server_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"       = local.docker_registry_server_password
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.application_insights_staging.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.application_insights_staging.connection_string
  }

  site_config {
    always_on         = true
    http2_enabled     = true
    ftps_state        = "Disabled"
    health_check_path = "/api/healthcheck/poi"
    # acr_use_managed_identity_credentials = true
    linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-poi:${local.base_image_tag}"
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
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      site_config[0].linux_fx_version
    ]
  }
}

# resource "azurerm_key_vault_access_policy" "key_vault_access_policy_api-poi_staging" {
#   key_vault_id = azurerm_key_vault.key_vault.id
#   tenant_id    = azurerm_app_service_slot.app_service_api-poi_staging.identity[0].tenant_id
#   object_id    = azurerm_app_service_slot.app_service_api-poi_staging.identity[0].principal_id

#   secret_permissions = [
#     "Get"
#   ]
# }

# resource "azurerm_role_assignment" "cr_role_assignment_api-poi_staging" {
#   scope                = azurerm_container_registry.container_registry.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_app_service_slot.app_service_api-poi_staging.identity[0].principal_id
# }