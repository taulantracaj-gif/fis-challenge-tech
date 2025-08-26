
data "azurerm_key_vault" "infra_key_vault" {
  name                = "kv-tr-infr"
  resource_group_name = var.kv_resource_group_name
}


