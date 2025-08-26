locals {
  vnet_configuration = {
    vnet_address_space = var.virtual_network_address_space
  }
  vnet_configuration_logs = {
    diagnostic_logs = [
      {
        category = "VMProtectionAlerts"
        retention_policy = {
          enabled = false
        }
      }
    ],
    diagnostic_metric = [
      {
        category = "AllMetrics"
        enabled  = false
        retention_policy = {
          enabled = false
        }
      }
    ]
  }
}
