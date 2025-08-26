# Create a Subnet
resource "azurerm_subnet" "subnet" {
  name                                          = var.subnet_name
  virtual_network_name                          = var.vnet_name
  resource_group_name                           = var.resource_group_name
  address_prefixes                              = [element(var.address_range, 0)]
  private_endpoint_network_policies             = var.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
}

module "virtual_network_subnets_nsg" {
  source                     = "../virtual-network-subnet-nsg"
  active                     = var.active
  nsg_name                   = "nsg-${var.subnet_name}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  subnet_id                  = azurerm_subnet.subnet.id
  network_rule               = var.network_rule
  diagnostic_active          = var.diagnostic_active
  log_analytics_workspace_id = var.log_analytics_workspace_id
  nsg_diagnostic_logs        = var.nsg_diagnostic_logs
}
