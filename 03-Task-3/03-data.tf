data "azurerm_private_dns_zone" "acr_private_dns_zone" {
  name                = var.private_acr_dns_zone
  resource_group_name = var.dns_zone_resource_group_name
}

data "azurerm_client_config" "current" {}
