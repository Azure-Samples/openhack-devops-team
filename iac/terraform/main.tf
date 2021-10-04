############################################
## RESOURCE GROUP                         ##
############################################

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = local.location
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
    tier = "Standard"
    size = "S1"
  }
}

############################################
## APP SERVICE - TRIPVIEWER               ##
############################################

resource "azurerm_app_service" "app_service_tripviewer" {
  depends_on = [
  ]
  name                = local.app_service_tripviewer_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true

  app_settings = {
    "BING_MAPS_KEY"      = local.bing_maps_key
    "USER_ROOT_URL"      = "https://${azurerm_app_service.app_service_api-userprofile.default_site_hostname}"
    "USER_JAVA_ROOT_URL" = "https://${azurerm_app_service.app_service_api-user-java.default_site_hostname}"
    "TRIPS_ROOT_URL"     = "https://${azurerm_app_service.app_service_api-trips.default_site_hostname}"
    "POI_ROOT_URL"       = "https://${azurerm_app_service.app_service_api-poi.default_site_hostname}"
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/tripviewer:latest"
  }
}

############################################
## APP SERVICE - API-POI                  ##
############################################

resource "azurerm_app_service" "app_service_api-poi" {
  depends_on = [
    null_resource.db_datainit
  ]
  name                = local.app_service_api-poi_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true

  app_settings = {
    "SQL_USER"      = local.mssql_server_administrator_login
    "SQL_PASSWORD"  = local.mssql_server_administrator_login_password
    "SQL_SERVER"    = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"    = local.mssql_database_name
    "WEBSITES_PORT" = "8080"
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-poi:${local.base_image_tag}"
  }
}

resource "azurerm_app_service_slot" "app_service_api-poi_staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.app_service_api-poi.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  https_only          = true

  app_settings = {
    "SQL_USER"      = local.mssql_server_administrator_login
    "SQL_PASSWORD"  = local.mssql_server_administrator_login_password
    "SQL_SERVER"    = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"    = local.mssql_database_name
    "WEBSITES_PORT" = "8080"
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }
  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-poi:${local.base_image_tag}"
  }
}

############################################
## APP SERVICE - API-TRIPS                ##
############################################

resource "azurerm_app_service" "app_service_api-trips" {
  depends_on = [
    null_resource.db_datainit
  ]
  name                = local.app_service_api-trips_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true

  app_settings = {
    "SQL_USER"     = local.mssql_server_administrator_login
    "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    "SQL_SERVER"   = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"   = local.mssql_database_name
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-trips:${local.base_image_tag}"
  }
}

resource "azurerm_app_service_slot" "app_service_api-trips_staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.app_service_api-trips.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  https_only          = true

  app_settings = {
    "SQL_USER"     = local.mssql_server_administrator_login
    "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    "SQL_SERVER"   = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"   = local.mssql_database_name
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-trips:${local.base_image_tag}"
  }
}

############################################
## APP SERVICE - API-USER-JAVA            ##
############################################

resource "azurerm_app_service" "app_service_api-user-java" {
  depends_on = [
    null_resource.db_datainit
  ]
  name                = local.app_service_api-user-java_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true

  app_settings = {
    "SQL_USER"     = local.mssql_server_administrator_login
    "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    "SQL_SERVER"   = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"   = local.mssql_database_name
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-user-java:${local.base_image_tag}"
  }
}

resource "azurerm_app_service_slot" "app_service_api-user-java_staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.app_service_api-user-java.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  https_only          = true

  app_settings = {
    "SQL_USER"     = local.mssql_server_administrator_login
    "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    "SQL_SERVER"   = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"   = local.mssql_database_name
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-user-java:${local.base_image_tag}"
  }
}

############################################
## APP SERVICE - API-USERPROFILE          ##
############################################

resource "azurerm_app_service" "app_service_api-userprofile" {
  depends_on = [
    null_resource.db_datainit
  ]
  name                = local.app_service_api-userprofile_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = true

  app_settings = {
    "SQL_USER"     = local.mssql_server_administrator_login
    "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    "SQL_SERVER"   = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"   = local.mssql_database_name
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-userprofile:${local.base_image_tag}"
  }
}

resource "azurerm_app_service_slot" "app_service_api-userprofile_staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.app_service_api-userprofile.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  https_only          = true

  app_settings = {
    "SQL_USER"     = local.mssql_server_administrator_login
    "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    "SQL_SERVER"   = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    "SQL_DBNAME"   = local.mssql_database_name
    # "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.container_registry.login_server}"
    # "DOCKER_REGISTRY_SERVER_USERNAME" = "${azurerm_container_registry.container_registry.admin_username}"
    # "DOCKER_REGISTRY_SERVER_PASSWORD" = "${azurerm_container_registry.container_registry.admin_password}"
  }

  site_config {
    always_on = true
    # linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/devopsoh/api-userprofile:${local.base_image_tag}"
  }
}

############################################
## CONTAINER GROUP - SIMULATOR            ##
############################################

resource "azurerm_container_group" "container_group_simulator" {
  depends_on = [
    null_resource.docker_simulator
  ]
  name                = local.container_group_simulator_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  ip_address_type     = "public"
  dns_name_label      = local.container_group_simulator_name
  os_type             = "Linux"

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
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "SQL_USER"           = local.mssql_server_administrator_login
      "SQL_SERVER"         = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
      "SQL_DBNAME"         = local.mssql_database_name
      "TEAM_NAME"          = local.team_name
      "USER_ROOT_URL"      = "https://${azurerm_app_service.app_service_api-userprofile.default_site_hostname}"
      "USER_JAVA_ROOT_URL" = "https://${azurerm_app_service.app_service_api-user-java.default_site_hostname}"
      "TRIPS_ROOT_URL"     = "https://${azurerm_app_service.app_service_api-trips.default_site_hostname}"
      "POI_ROOT_URL"       = "https://${azurerm_app_service.app_service_api-poi.default_site_hostname}"
    }

    secure_environment_variables = {
      "SQL_PASSWORD" = local.mssql_server_administrator_login_password
    }
  }
}
