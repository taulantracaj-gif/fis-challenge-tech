
# Create NSG
resource "azurerm_network_security_group" "azure-nsg" {
  count               = var.active ? 1 : 0
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    iterator = rule
    for_each = var.network_rule
    content {
      name                       = rule.value.name
      priority                   = rule.value.priority
      direction                  = rule.value.direction
      access                     = rule.value.access
      protocol                   = rule.value.protocol
      source_port_range          = can(rule.value.source_port_range) ? rule.value.source_port_range : null
      source_port_ranges         = can(rule.value.source_port_ranges) ? rule.value.source_port_ranges : null
      destination_port_range     = can(rule.value.destination_port_range) ? rule.value.destination_port_range : null
      destination_port_ranges    = can(rule.value.destination_port_ranges) ? rule.value.destination_port_ranges : null
      source_address_prefix      = can(rule.value.source_address_prefix) ? rule.value.source_address_prefix : null
      source_address_prefixes    = can(rule.value.source_address_prefixes) ? rule.value.source_address_prefixes : null
      destination_address_prefix = rule.value.destination_address_prefix

    }
  }

  tags = merge(var.tagging, var.extra_tags)
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-ass-subnet" {
  count                     = var.active ? 1 : 0
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.azure-nsg[count.index].id
}

module "diagnostic_settings" {
  count                      = var.active && var.diagnostic_active ? 1 : 0
  source                     = "../diagnostic_setting"
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_network_security_group.azure-nsg[count.index].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_logs            = var.nsg_diagnostic_logs
}
