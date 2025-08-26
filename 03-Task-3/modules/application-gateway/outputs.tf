# Create Outputs

# Azure App GW NAME
output "app_gw_name" {
  value = azurerm_application_gateway.app_gw.name
}

# Azure App GW ID
output "app_gw_id" {
  value = azurerm_application_gateway.app_gw.id
}
