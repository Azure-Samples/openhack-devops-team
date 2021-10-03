output "appServiceTripviewerHostname" {
  description = "Hostname of Tripviewer"
  value       = azurerm_app_service.app_service_tripviewer.default_site_hostname
}
output "appServiceApiPoiHostname" {
  description = "Hostname of API-POI"
  value       = azurerm_app_service.app_service_api-poi.default_site_hostname
}
output "appServiceApiTripsHostname" {
  description = "Hostname of API-TRIPS"
  value       = azurerm_app_service.app_service_api-trips.default_site_hostname
}
output "appServiceApiUserjavaHostname" {
  description = "Hostname of API-USER-JAVA"
  value       = azurerm_app_service.app_service_api-user-java.default_site_hostname
}
output "appServiceApiUserprofileHostname" {
  description = "Hostname of API-USERPROFILE"
  value       = azurerm_app_service.app_service_api-userprofile.default_site_hostname
}