locals {
  subnets = {
    "virtual_network_subnet_priva" = {
      subnet_name                                   = "priva-${module.naming.subnet.name_unique}"
      address_range                                 = var.virtual_network_subnet_priva_address_prefix
      active                                        = true
      diagnostic_active                             = true
      network_rule                                  = local.network_rule_priva
      log_analytics_workspace_id                    = azurerm_log_analytics_workspace.loganalytic.id
      diagnostic_logs                               = local.network_securitygroup_logs
      private_endpoint_network_policies_enabled     = "Enabled"
      private_link_service_network_policies_enabled = false
    },
    "virtual_network_subnet_puba" = {
      subnet_name                                   = "puba-${module.naming.subnet.name_unique}"
      address_range                                 = var.virtual_network_subnet_puba_address_prefix
      active                                        = true
      diagnostic_active                             = true
      network_rule                                  = local.network_rule_pub
      log_analytics_workspace_id                    = azurerm_log_analytics_workspace.loganalytic.id
      diagnostic_logs                               = local.network_securitygroup_logs
      private_endpoint_network_policies_enabled     = "Enabled"
      private_link_service_network_policies_enabled = true
    },
    "virtual_network_subnet_aks" = {
      subnet_name                                   = "aks-${module.naming.subnet.name_unique}"
      address_range                                 = var.virtual_network_subnet_aks_address_prefix
      active                                        = true
      diagnostic_active                             = true
      network_rule                                  = local.network_rule_aks
      log_analytics_workspace_id                    = azurerm_log_analytics_workspace.loganalytic.id
      diagnostic_logs                               = local.network_securitygroup_logs
      private_endpoint_network_policies_enabled     = "Enabled"
      private_link_service_network_policies_enabled = false
    }
  }
}
