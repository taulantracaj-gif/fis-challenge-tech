
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "link_to_${var.name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone   #azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.virtual_network_id #"/subscriptions/${var.subscription_id}/resourceGroups/${each.value.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${each.key}"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
