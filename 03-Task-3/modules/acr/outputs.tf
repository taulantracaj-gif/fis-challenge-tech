# Create Outputs

output "container_registry_name" {
  value = azurerm_container_registry.acr.name
}

output "container_registry_id" {
  value = azurerm_container_registry.acr.id
}

output "container_registry_uri" {
  value = azurerm_container_registry.acr.login_server
}
