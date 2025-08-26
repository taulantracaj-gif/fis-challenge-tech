locals {
  org       = "tr"
  prj       = "fis"
  env       = var.environment
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}
