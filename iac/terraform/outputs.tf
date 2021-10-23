output "appServiceApiPoiHealthcheck" {
  description = "Hostname of API-POI"
  value       = "${azurerm_app_service.app_service_api-poi.default_site_hostname}/api/healthcheck/poi"
}
output "appServiceApiTripsHealthcheck" {
  description = "Hostname of API-TRIPS"
  value       = "${azurerm_app_service.app_service_api-trips.default_site_hostname}/api/healthcheck/trips"
}
output "appServiceApiUserjavaHealthcheck" {
  description = "Hostname of API-USER-JAVA"
  value       = "${azurerm_app_service.app_service_api-userjava.default_site_hostname}/api/healthcheck/user-java"
}
output "appServiceApiUserprofileHealthcheck" {
  description = "Hostname of API-USERPROFILE"
  value       = "${azurerm_app_service.app_service_api-userprofile.default_site_hostname}/api/healthcheck/user"
}