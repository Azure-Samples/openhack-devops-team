data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                      = local.storage_account_name
  location                  = azurerm_resource_group.resource_group.location
  resource_group_name       = azurerm_resource_group.resource_group.name
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_application_insights" "application_insights" {
  name                = local.application_insights_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  lifecycle {
    ignore_changes = [
      tags,
      kind
    ]
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = local.function_app_name
  location                   = azurerm_resource_group.resource_group.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"
  https_only                 = true

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key
    "FUNCTIONS_WORKER_RUNTIME"       = "dotnet"
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    ftps_state                = "Disabled"
    dotnet_framework_version  = "v4.0"
    use_32_bit_worker_process = false
  }

  lifecycle {
    ignore_changes = [
      tags,
      # app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"],
      # app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      # app_settings["APPINSIGHTS_INSTRUMENTATIONKEY"],
      # app_settings["FUNCTIONS_WORKER_RUNTIME"]
    ]
  }
}

# resource "azurerm_app_service_source_control" "app_service_source_control" {
#   app_id   = azurerm_function_app.function_app.id
#   repo_url = "https://github.com/Azure-Samples/KeyVault-Rotation-SQLPassword-Csharp.git"
#   branch   = "main"
#   manual_integration = true
#   # scm_type           = "ExternalGit"
# }

resource "azurerm_key_vault_access_policy" "key_vault_access_policy_function_app" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_function_app.function_app.identity[0].tenant_id
  object_id    = azurerm_function_app.function_app.identity[0].principal_id

  secret_permissions = [
    "Get", "List", "Set"
  ]
}

# resource "azurerm_eventgrid_event_subscription" "eventgrid_event_subscription" {
#   name  = "${data.azurerm_key_vault.key_vault.name}-${var.secret_name}-${azurerm_function_app.function_app.name}"
#   scope = data.azurerm_key_vault.key_vault.id

#   azure_function_endpoint {
#     function_id                       = "${azurerm_function_app.function_app.id}/functions/AKVSQLRotation"
#     max_events_per_batch              = 1
#     preferred_batch_size_in_kilobytes = 64
#   }

#   subject_filter {
#     subject_begins_with = var.secret_name
#     subject_ends_with   = var.secret_name
#   }

#   included_event_types = [
#     "Microsoft.KeyVault.SecretNearExpiry"
#   ]
# }