#https://github.com/Azure/terraform-azurerm-naming#output_virtual_network

module "naming" {
  source                 = "Azure/naming/azurerm"
  suffix                 = ["${local.org}", "${local.prj}", "${local.env}", "${var.location}"]
  unique-include-numbers = true
  unique-length          = 4
}


# Terraform Resource to Create Azure Resource Group with Input Variables defined in variables.tf
resource "azurerm_resource_group" "global_rg" {
  name     = module.naming.resource_group.name_unique
  location = var.location

  # Add Tags
  tags = merge(var.tags, {
    ResourceType = "Resource Group"
    }
  )
}


# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "loganalytic" {
  name                = module.naming.log_analytics_workspace.name_unique
  location            = var.location
  resource_group_name = azurerm_resource_group.global_rg.name
  retention_in_days   = 90
  tags = merge(var.tags, {
    ResourceType = "Log Analytics Workspace"
  })
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create Virtual Network
resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "vnet-${local.org}-${local.prj}-${local.env}-${var.location}"
  location            = var.location                          #azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.global_rg.name #azurerm_resource_group.aks_rg.name
  address_space       = local.vnet_configuration.vnet_address_space
  tags = merge(var.tags, {
    ResourceType = "Virtual Network"
  })
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

module "diagnostic_settings_virtualnetwork" {
  count                      = var.vnet_diagnostic_active ? 1 : 0
  source                     = ".//modules/diagnostic_setting"
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_virtual_network.virtualnetwork.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalytic.id
  diagnostic_logs            = local.vnet_configuration_logs.diagnostic_logs
  diagnostic_metric          = local.vnet_configuration_logs.diagnostic_metric
}


# Create a Subnet
module "virtual_network_subnets" {
  source                                        = ".//modules/virtual-network-subnet"
  for_each                                      = local.subnets
  resource_group_name                           = azurerm_resource_group.global_rg.name
  vnet_name                                     = azurerm_virtual_network.virtualnetwork.name
  subnet_name                                   = each.value["subnet_name"]
  location                                      = var.location
  address_range                                 = each.value["address_range"]
  active                                        = each.value["active"]
  diagnostic_active                             = each.value["diagnostic_active"]
  network_rule                                  = each.value["network_rule"]
  log_analytics_workspace_id                    = each.value["log_analytics_workspace_id"]
  nsg_diagnostic_logs                           = each.value["diagnostic_logs"]
  private_endpoint_network_policies_enabled     = each.value["private_endpoint_network_policies_enabled"]
  private_link_service_network_policies_enabled = each.value["private_link_service_network_policies_enabled"]
}

# Create Azure AD Group in Active Directory 

module "az_ad_group_aks" {
  source        = ".//modules/az-ad-group"
  environment   = local.env
  ad_group_name = "aks ${local.env} administrators"
}

module "az_ad_group_aks_appdev" {
  source        = ".//modules/az-ad-group"
  environment   = local.env
  ad_group_name = "aks ${local.env} appdev"
}

module "az_ad_group_aks_opssre" {
  source        = ".//modules/az-ad-group"
  environment   = local.env
  ad_group_name = "aks ${local.env} opssre"
}

resource "azurerm_user_assigned_identity" "ua_identity" {
  location            = var.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.global_rg.name
  tags = merge(var.tags, {
    ResourceType = "User Assigned Identity"
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

module "acr" {
  source                        = ".//modules/acr"
  environment                   = local.env
  location                      = var.location
  resource_group_name           = azurerm_resource_group.global_rg.name
  acrname                       = module.naming.container_registry.name_unique
  acr_sku                       = var.acr_sku
  admin_enabled                 = true
  public_network_access_enabled = false
  georeplication_locations      = []
  log_analytics_workspace_id    = azurerm_log_analytics_workspace.loganalytic.id
  acr_diagnostic_active         = local.acr_configuration.diagnostic_active
  acr_diagnostic_logs           = local.acr_configuration.diagnostic_logs
  acr_diagnostic_metric         = local.acr_configuration.diagnostic_metric
  tagging                       = var.tags
  extra_tags = {
    ResourceType = "Container Registry"
  }
}

module "acr_private_endpoint" {
  source                         = ".//modules/private-endpoints"
  name                           = "private-ep-${module.acr.container_registry_name}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.global_rg.name
  subnet_id                      = module.virtual_network_subnets["virtual_network_subnet_priva"].subnet_id
  private_connection_resource_id = module.acr.container_registry_id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [data.azurerm_private_dns_zone.acr_private_dns_zone.id]
  tags                           = var.tags
  extra_tags = {
    ResourceType = "Private Endpoint"
  }
}

resource "azurerm_public_ip" "pub_ip" {
  name                = module.naming.public_ip.name_unique
  resource_group_name = azurerm_resource_group.global_rg.name #azurerm_resource_group.aks_rg.name
  location            = var.location                          #azurerm_resource_group.aks_rg.location
  allocation_method   = local.public_ip_configuration.public_ip_allocation_method
  sku                 = local.public_ip_configuration.public_ip_sku
  zones               = local.public_ip_configuration.zones
  tags = merge(var.tags, {
    ResourceType = "Public IP"
    Purpose      = "Public Ip for Application Gateway"
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

module "waf_policy_appgw" {
  source                  = ".//modules/waf-policy"
  location                = var.location
  resource_group_name     = azurerm_resource_group.global_rg.name #module.acr.container_registry_resource_group_name 
  waf_policy_name         = module.naming.firewall_policy.name_unique
  waf_policy_settings     = local.waf_configuration.policy_settings
  waf_exclusions          = local.waf_configuration.exclusion
  waf_rule_group_override = local.waf_configuration.rule_group_override
  #waf_disabled_rule_group     = local.waf_configuration.disabled_rule_group
  waf_custom_rules = local.waf_custom_rules.rules
  tagging          = var.tags
  extra_tags = {
    ResourceType = "Waf Policy"
  }
}


module "appgw" {
  source                               = ".//modules/application-gateway"
  location                             = var.location
  resource_group_name                  = azurerm_resource_group.global_rg.name
  appgw_name                           = module.naming.application_gateway.name_unique
  waf_policy                           = module.waf_policy_appgw.waf_policy_id
  appgw_zones                          = local.app_gw_configuration.zones
  appgw_sku                            = local.app_gw_configuration.sku
  appgw_ip_configuration_name          = module.naming.firewall_ip_configuration.name_unique
  appg_gw_subnet_id                    = module.virtual_network_subnets["virtual_network_subnet_puba"].subnet_id
  appgw_frontend_ports                 = local.app_gw_configuration.frontend_port
  appgw_frontend_ip_configuration_name = local.app_gw_configuration.appgw_frontend_ip_configuration_name
  appgw_public_id                      = azurerm_public_ip.pub_ip.id
  appgw_backend_address_pool_name      = local.app_gw_configuration.appgw_backend_address_pool_name
  app_gw_backend_http_settings         = local.app_gw_configuration.app_gw_backend_http_settings
  app_gw_request_routing_rule          = local.app_gw_configuration.app_gw_request_routing_rule
  app_gw_http_listener                 = local.app_gw_configuration.app_gw_http_listener
  log_analytics_workspace_id           = azurerm_log_analytics_workspace.loganalytic.id
  app_gw_diagnostic_active             = local.app_gw_configuration_logs.diagnostic_active
  app_gw_diagnostic_logs               = local.app_gw_configuration_logs.diagnostic_logs
  app_gw_diagnostic_metric             = local.app_gw_configuration_logs.diagnostic_metric
  app_gw_identity_ids                  = [azurerm_user_assigned_identity.ua_identity.id]
  tagging                              = var.tags
  extra_tags = {
    ResourceType = "Application Gateway"
  }
}

resource "azapi_resource" "ssh_public_key_newest" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "ssh-aks-${local.org}-${local.prj}-${local.env}"
  location  = var.location
  parent_id = azurerm_resource_group.global_rg.id
}


resource "azapi_resource_action" "ssh_public_key_gen_newest" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key_newest.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
  lifecycle {
    ignore_changes = [

    ]
  }
}

module "aks_cluster" {
  source = ".//modules/aks-cluster"
  #environment                                  = local.env
  location                                     = var.location
  resource_group_name                          = azurerm_resource_group.global_rg.name
  aks_name                                     = local.aks_configuration.aks_name
  aks_dns_prefix                               = lower(local.aks_configuration.aks_name)
  aks_private_cluster_enabled                  = local.aks_configuration.aks_private_cluster_enabled
  aks_sku_tier                                 = local.aks_configuration.aks_sku_tier
  aks_workload_identity_enabled                = local.aks_configuration.aks_workload_identity_enabled
  aks_oidc_issuer_enabled                      = local.aks_configuration.aks_oidc_issuer_enabled
  aks_open_service_mesh_enabled                = local.aks_configuration.aks_open_service_mesh_enabled
  aks_image_cleaner_enabled                    = local.aks_configuration.aks_image_cleaner_enabled
  aks_azure_policy_enabled                     = local.aks_configuration.aks_azure_policy_enabled
  aks_http_application_routing_enabled         = local.aks_configuration.aks_http_application_routing_enabled
  aks_ingress_application_gateway              = local.aks_configuration.aks_ingress_application_gateway
  aks_role_based_access_control_enabled        = local.aks_configuration.aks_role_based_access_control_enabled
  aks_default_node_pool_name                   = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_name
  aks_default_node_pool_vm_size                = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_vm_size
  aks_version                                  = var.aks_version
  aks_vnet_subnet_id                           = module.virtual_network_subnets["virtual_network_subnet_aks"].subnet_id
  aks_default_node_pool_availability_zones     = local.aks_configuration.zones
  aks_default_node_pool_node_labels            = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_node_labels
  aks_default_node_pool_node_taints            = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_node_taints
  aks_default_node_pool_enable_auto_scaling    = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_enable_auto_scaling
  aks_default_node_pool_enable_host_encryption = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_enable_host_encryption
  aks_default_node_pool_enable_node_public_ip  = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_enable_node_public_ip
  aks_default_node_pool_max_pods               = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_max_pods
  aks_default_node_pool_max_count              = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_max_count
  aks_default_node_pool_min_count              = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_min_count
  aks_default_node_pool_node_count             = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_node_count
  aks_default_node_pool_os_disk_type           = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_os_disk_type
  aks_os_disk_size_gb                          = local.aks_configuration.aks_default_node_pool.aks_os_disk_size_gb
  aks_default_node_pool_type                   = local.aks_configuration.aks_default_node_pool.aks_default_node_pool_type
  linux_admin_username                         = local.aks_configuration.aks_linux_profile.linux_admin_username
  ssh_public_key                               = local.aks_configuration.aks_linux_profile.ssh_public_key
  aks_umi_type                                 = local.aks_configuration.aks_identity.aks_umi_type
  aks_umi_ids                                  = azurerm_user_assigned_identity.ua_identity.id
  aks_network_profile_plugin                   = local.aks_configuration.aks_network_profile.aks_network_profile_plugin
  aks_network_profile_dns_service_ip           = local.aks_configuration.aks_network_profile.aks_network_profile_dns_service_ip
  aks_network_profile_docker_bridge_cidr       = local.aks_configuration.aks_network_profile.aks_network_profile_docker_bridge_cidr
  aks_network_profile_service_cidr             = local.aks_configuration.aks_network_profile.aks_network_profile_service_cidr
  oms_agent                                    = local.aks_configuration.aks_oms_agent
  monitor_metrics                              = local.aks_configuration.monitor_metrics
  log_analytics_workspace_id                   = local.aks_configuration.log_analytics_workspace_id
  aks_diagnostic_active                        = local.aks_configuration_logs.diagnostic_active
  aks_diagnostic_logs                          = local.aks_configuration_logs.diagnostic_logs
  aks_diagnostic_metric                        = local.aks_configuration_logs.diagnostic_metric
  admin_group_object_ids                       = [module.az_ad_group_aks.azure_ad_group_objectid, var.owners_object_id]
  tagging                                      = var.tags
  extra_tags = {
    ResourceType = "Azure Kubernetes Cluster"
    Purpose      = "${local.env} Node"
  }
}


module "aks_node_pool" {
  source                 = ".//modules/aks-node-pool"
  kubernetes_cluster_id  = local.aks_node_configuration.kubernetes_cluster_id
  name                   = local.aks_node_configuration.name
  vm_size                = local.aks_node_configuration.vm_size
  mode                   = local.aks_node_configuration.mode
  node_labels            = local.aks_node_configuration.node_labels
  availability_zones     = local.aks_node_configuration.zones
  vnet_subnet_id         = local.aks_node_configuration.vnet_subnet_id
  enable_auto_scaling    = local.aks_node_configuration.enable_auto_scaling
  enable_host_encryption = local.aks_node_configuration.enable_host_encryption
  enable_node_public_ip  = local.aks_node_configuration.enable_node_public_ip
  orchestrator_version   = local.aks_node_configuration.orchestrator_version
  max_pods               = local.aks_node_configuration.max_pods
  max_count              = local.aks_node_configuration.max_count
  min_count              = local.aks_node_configuration.min_count
  node_count             = local.aks_node_configuration.node_count
  os_disk_size_gb        = local.aks_node_configuration.os_disk_size_gb
  os_disk_type           = local.aks_node_configuration.os_disk_type
  os_type                = local.aks_node_configuration.os_type
  priority               = local.aks_node_configuration.priority
  tags                   = var.tags
  extra_tags = {
    ResourceType = "Azure Kubernetes Node Pool"
    Purpose      = "${local.env} Node"
  }
}

module "aks_node_pool_server" {
  source                 = ".//.//modules/aks-node-pool"
  kubernetes_cluster_id  = local.aks_node_configuration_server.kubernetes_cluster_id
  name                   = local.aks_node_configuration_server.name
  vm_size                = local.aks_node_configuration_server.vm_size
  mode                   = local.aks_node_configuration_server.mode
  node_labels            = local.aks_node_configuration_server.node_labels
  availability_zones     = local.aks_node_configuration_server.zones
  vnet_subnet_id         = local.aks_node_configuration_server.vnet_subnet_id
  enable_auto_scaling    = local.aks_node_configuration_server.enable_auto_scaling
  enable_host_encryption = local.aks_node_configuration_server.enable_host_encryption
  enable_node_public_ip  = local.aks_node_configuration_server.enable_node_public_ip
  orchestrator_version   = local.aks_node_configuration_server.orchestrator_version
  max_pods               = local.aks_node_configuration_server.max_pods
  max_count              = local.aks_node_configuration_server.max_count
  min_count              = local.aks_node_configuration_server.min_count
  node_count             = local.aks_node_configuration_server.node_count
  os_disk_size_gb        = local.aks_node_configuration_server.os_disk_size_gb
  os_disk_type           = local.aks_node_configuration_server.os_disk_type
  os_type                = local.aks_node_configuration_server.os_type
  priority               = local.aks_node_configuration_server.priority
  tags                   = var.tags
  extra_tags = {
    ResourceType = "Azure Kubernetes Node Pool"
    Purpose      = "${local.env} Second Node 2"
  }
}

module "acr_private_dns_zone_link" {
  source              = ".//modules/private-dns-zone-link"
  name                = azurerm_virtual_network.virtualnetwork.name
  resource_group_name = var.dns_zone_resource_group_name
  private_dns_zone    = data.azurerm_private_dns_zone.acr_private_dns_zone.name
  virtual_network_id  = azurerm_virtual_network.virtualnetwork.id
}


resource "azurerm_management_lock" "resource-group-level" {
  name       = "${azurerm_resource_group.global_rg.name}-prevent-deletion"
  scope      = azurerm_resource_group.global_rg.id
  lock_level = "CanNotDelete"
  notes      = "Items can't be deleted in this Resource Group!"
}
