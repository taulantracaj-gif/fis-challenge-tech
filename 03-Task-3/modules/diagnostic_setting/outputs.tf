output "name" {
  value       = azurerm_monitor_diagnostic_setting.settings.name
  description = "Specifies the name of the diagnostics"
}

output "id" {
  value       = azurerm_monitor_diagnostic_setting.settings.id
  description = "Specifies the ID of the diagnostics"
}
