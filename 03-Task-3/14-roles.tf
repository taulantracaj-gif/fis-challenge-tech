resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_resource_group.global_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.ua_identity.id
}

resource "azurerm_role_assignment" "aks_uami_contrbutor_log_analytics" {
  scope                = azurerm_resource_group.global_rg.name
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_user_assigned_identity.ua_identity.id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks_cluster.kubelet_identity_object_id
}

resource "azurerm_role_assignment" "agic_uami_appgw_rg_contributor" {
  scope                = azurerm_resource_group.global_rg.id
  role_definition_name = "Contributor"
  principal_id         = module.aks_cluster.agic_managed_identity_object_id
}

resource "azurerm_role_assignment" "fis_aks_appdev_role_assign" {
  scope                = module.aks_cluster.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.az_ad_group_aks_appdev.azure_ad_group_objectid
}

resource "azurerm_role_assignment" "fis_aks_opssre_role_assign" {
  scope                = module.aks_cluster.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.az_ad_group_aks_opssre.azure_ad_group_objectid
}
