############################################
## RESOURCE GROUP                         ##
############################################

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = local.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

############################################
## CONTAINER REGISTRY                     ##
############################################

resource "azurerm_container_registry" "container_registry" {
  name                = local.container_registry_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"
  admin_enabled       = true

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

############################################
## SQL SERVER                             ##
############################################

resource "azurerm_mssql_server" "mssql_server" {
  name                         = local.mssql_server_name
  location                     = azurerm_resource_group.resource_group.location
  resource_group_name          = azurerm_resource_group.resource_group.name
  version                      = "12.0"
  administrator_login          = local.mssql_server_administrator_login
  administrator_login_password = local.mssql_server_administrator_login_password
  minimum_tls_version          = "1.2"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule_myip" {
  name             = "SetupAccount"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = local.mssql_firewall_rule_myip
  end_ip_address   = local.mssql_firewall_rule_myip
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule_azure" {
  name             = "AzureAccess"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

############################################
## SQL DATABASE                           ##
############################################

resource "azurerm_mssql_database" "mssql_database" {
  name      = local.mssql_database_name
  server_id = azurerm_mssql_server.mssql_server.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "S0"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

############################################
## APP SERVICE PLAN                       ##
############################################

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  kind                = "linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

############################################
## APP SERVICE - TRIPVIEWER               ##
############################################

resource "azurerm_app_service" "app_service_tripviewer" {
  depends_on = [
    null_resource.docker_tripviewer
  ]
  name                = local.app_service_tripviewer_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true
  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "BING_MAPS_KEY"                         = local.bing_maps_key
    "USER_ROOT_URL"                         = "https://${azurerm_app_service.app_service_api-userprofile.default_site_hostname}"
    "USER_JAVA_ROOT_URL"                    = "https://${azurerm_app_service.app_service_api-userjava.default_site_hostname}"
    "TRIPS_ROOT_URL"                        = "https://${azurerm_app_service.app_service_api-trips.default_site_hostname}"
    "POI_ROOT_URL"                          = "https://${azurerm_app_service.app_service_api-poi.default_site_hostname}"
    "STAGING_USER_ROOT_URL"                 = "https://${azurerm_app_service_slot.app_service_api-userprofile_staging.default_site_hostname}"
    "STAGING_USER_JAVA_ROOT_URL"            = "https://${azurerm_app_service_slot.app_service_api-userjava_staging.default_site_hostname}"
    "STAGING_TRIPS_ROOT_URL"                = "https://${azurerm_app_service_slot.app_service_api-trips_staging.default_site_hostname}"
    "STAGING_POI_ROOT_URL"                  = "https://${azurerm_app_service_slot.app_service_api-poi_staging.default_site_hostname}"
    "DOCKER_REGISTRY_SERVER_URL"            = "https://${azurerm_container_registry.container_registry.login_server}"
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.application_insights.connection_string
  }

  site_config {
    always_on                            = true
    http2_enabled                        = true
    ftps_state                           = "Disabled"
    acr_use_managed_identity_credentials = true
    linux_fx_version                     = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/tripviewer:latest"
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
      tags
    ]
  }
}

resource "azurerm_role_assignment" "cr_role_assignment_tripviewer" {
  scope                = azurerm_container_registry.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service.app_service_tripviewer.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy_tripviewer" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_app_service.app_service_tripviewer.identity[0].tenant_id
  object_id    = azurerm_app_service.app_service_tripviewer.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}

############################################
## APPLICATION INSIGHTS                   ##
############################################

resource "azurerm_application_insights" "application_insights" {
  name                = local.application_insights_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

resource "azurerm_application_insights" "application_insights_staging" {
  name                = "${local.application_insights_name}staging"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

############################################
## UAMI                                   ##
############################################

# resource "azurerm_user_assigned_identity" "user_assigned_identity" {
#   name                = local.user_assigned_identity_name
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location
# }

############################################
## LOG ANALYTICS                          ##
############################################

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = local.log_analytics_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "free"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# resource "azurerm_log_analytics_solution" "log_analytics_solution_containerinsights" {
#   solution_name         = "ContainerInsights"
#   location              = azurerm_resource_group.resource_group.location
#   resource_group_name   = azurerm_resource_group.resource_group.name
#   workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
#   workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/ContainerInsights"
#   }

#   lifecycle {
#     ignore_changes = [
#       tags
#     ]
#   }
# }

resource "azurerm_log_analytics_solution" "log_analytics_solution_containers" {
  solution_name         = "Containers"
  location              = azurerm_resource_group.resource_group.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

############################################
## CONTAINER GROUP - SIMULATOR            ##
############################################

resource "azurerm_container_group" "container_group_simulator" {
  depends_on = [
    null_resource.docker_simulator
    # azurerm_role_assignment.cr_role_assignment_simulator
  ]
  name                = local.container_group_simulator_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  ip_address_type     = "public"
  dns_name_label      = local.container_group_simulator_name
  os_type             = "Linux"

  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     azurerm_user_assigned_identity.user_assigned_identity.id
  #   ]
  # }

  image_registry_credential {
    username = azurerm_container_registry.container_registry.admin_username
    password = azurerm_container_registry.container_registry.admin_password
    server   = azurerm_container_registry.container_registry.login_server
  }

  container {
    name   = "simulator"
    image  = "${azurerm_container_registry.container_registry.login_server}/devopsoh/simulator:latest"
    cpu    = "1"
    memory = "2"

    ports {
      port     = 8080
      protocol = "TCP"
    }

    environment_variables = {
      "SQL_USER"           = local.mssql_server_administrator_login
      "SQL_SERVER"         = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
      "SQL_DBNAME"         = local.mssql_database_name
      "TEAM_NAME"          = local.team_name
      "USER_ROOT_URL"      = "https://${azurerm_app_service.app_service_api-userprofile.default_site_hostname}"
      "USER_JAVA_ROOT_URL" = "https://${azurerm_app_service.app_service_api-userjava.default_site_hostname}"
      "TRIPS_ROOT_URL"     = "https://${azurerm_app_service.app_service_api-trips.default_site_hostname}"
      "POI_ROOT_URL"       = "https://${azurerm_app_service.app_service_api-poi.default_site_hostname}"
    }

    secure_environment_variables = {
      "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    }
  }

  diagnostics {
    log_analytics {
      log_type      = "ContainerInsights"
      workspace_id  = azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id
      workspace_key = azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# resource "azurerm_role_assignment" "cr_role_assignment_simulator" {
#   scope                = azurerm_container_registry.container_registry.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.user_assigned_identity.principal_id
# }

############################################
## KEY VAULT                              ##
############################################

resource "azurerm_key_vault" "key_vault" {
  name                       = local.key_vault_name
  location                   = azurerm_resource_group.resource_group.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy_sp" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ]
}

resource "azurerm_key_vault_secret" "key_vault_secret_sqlpassword" {
  name         = "SQL-PASSWORD"
  value        = azurerm_container_registry.container_registry.admin_password
  key_vault_id = azurerm_key_vault.key_vault.id

  # tags = {
  #   "CredentialId"       = local.mssql_server_administrator_login,
  #   "ProviderAddress"    = azurerm_mssql_server.mssql_server.id,
  #   "ValidityPeriodDays" = 30
  # }

  # expiration_date = timeadd(timestamp(), "30m")

  lifecycle {
    ignore_changes = [
      value,
      expiration_date
    ]
  }
}