resource "azurerm_container_registry" "acr" {
  name                          = var.acrname             #"${var.acrname}cr"
  resource_group_name           = var.resource_group_name #module.rg.resource_group_name
  location                      = var.location            #module.rg.location
  sku                           = var.acr_sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = merge(var.tagging, var.extra_tags)

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.acr_identity.id
    ]
  }

  dynamic "georeplications" {
    for_each = var.georeplication_locations

    content {
      location = georeplications.value
      tags     = merge(var.tagging, { ResourceType = "Geo Replication" })
    }
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_user_assigned_identity" "acr_identity" {
  resource_group_name = var.resource_group_name #module.rg.resource_group_name
  location            = var.location            #module.rg.location
  tags                = merge(var.tagging, { ResourceType = "User Assigned Identity" })

  name = "uai-${var.acrname}"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

module "diagnostic_settings" {
  count                      = var.acr_diagnostic_active ? 1 : 0
  source                     = "../diagnostic_setting"
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_logs            = var.acr_diagnostic_logs
  diagnostic_metric          = var.acr_diagnostic_metric
}
