
data "azurerm_key_vault" "infra_key_vault" {
  name                = "kv-tr-infr"
  resource_group_name = var.kv_resource_group_name
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "networkingRG" {
  name = var.network_resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-tr-northeurope"
  resource_group_name = data.azurerm_resource_group.networkingRG.name
}

data "azurerm_subnet" "agent" {
  name                 = "priva-snet-tr-northeurope-1234"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.networkingRG.name
}
