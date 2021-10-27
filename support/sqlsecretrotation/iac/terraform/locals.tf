locals {
  suffix                    = "sqlsecrot"
  resource_group_name       = "${var.resources_prefix}${local.suffix}rg"
  storage_account_name      = "${var.resources_prefix}${local.suffix}st"
  function_app_name         = "${var.resources_prefix}${local.suffix}func"
  app_service_plan_name     = "${var.resources_prefix}${local.suffix}plan"
  application_insights_name = "${var.resources_prefix}${local.suffix}appi"
}