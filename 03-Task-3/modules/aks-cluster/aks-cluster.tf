# Provision AKS Cluster
/*
1. Add Basic Cluster Settings
  - Get Latest Kubernetes Version from datasource (kubernetes_version)
  - Add Node Resource Group (node_resource_group)
2. Add Default Node Pool Settings
  - orchestrator_version (latest kubernetes version using datasource)
  - availability_zones
  - enable_auto_scaling
  - max_count, min_count
  - os_disk_size_gb
  - type
  - node_labels
  - tags
3. Enable MSI
4. Add On Profiles 
  - Azure Policy
  - Azure Monitor (Reference Log Analytics Workspace id)
5. RBAC & Azure AD Integration
6. Admin Profiles
  - Linux Profile
7. Network Profile
8. Cluster Tags  
*/

#Create Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                      = var.aks_name #"${var.aks_name}-${var.environment}"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.aks_dns_prefix #"${var.aks_name}-${var.environment}"
  private_cluster_enabled   = var.aks_private_cluster_enabled
  sku_tier                  = var.aks_sku_tier
  workload_identity_enabled = var.aks_workload_identity_enabled
  oidc_issuer_enabled       = var.aks_oidc_issuer_enabled
  open_service_mesh_enabled = var.aks_open_service_mesh_enabled
  #image_cleaner_enabled             = var.aks_image_cleaner_enabled is not allowed to enable since feature flag \"Microsoft.ContainerService/EnableImageCleanerPreview\" is not registered
  azure_policy_enabled              = var.aks_azure_policy_enabled #true
  http_application_routing_enabled  = var.aks_http_application_routing_enabled
  kubernetes_version                = var.aks_version
  node_resource_group               = "${var.resource_group_name}-nrg"
  role_based_access_control_enabled = var.aks_role_based_access_control_enabled

  dynamic "ingress_application_gateway" {
    for_each = try(var.aks_ingress_application_gateway.gateway_id, null) == null ? [] : [1]

    content {
      gateway_id = var.aks_ingress_application_gateway.gateway_id
    }
  }
  default_node_pool {
    name                 = var.aks_default_node_pool_name    #"systempool"
    vm_size              = var.aks_default_node_pool_vm_size #"Standard_D2_v2"
    orchestrator_version = var.aks_version
    vnet_subnet_id       = var.aks_vnet_subnet_id                       #azurerm_subnet.aks-default.id
    zones                = var.aks_default_node_pool_availability_zones #[1, 2, 3]
    node_labels          = var.aks_default_node_pool_node_labels
    #node_taints             = var.aks_default_node_pool_node_taints
    auto_scaling_enabled        = var.aks_default_node_pool_enable_auto_scaling    #true
    host_encryption_enabled     = var.aks_default_node_pool_enable_host_encryption #true
    node_public_ip_enabled      = var.aks_default_node_pool_enable_node_public_ip
    max_pods                    = var.aks_default_node_pool_max_pods
    min_count                   = var.aks_default_node_pool_min_count
    max_count                   = var.aks_default_node_pool_max_count
    node_count                  = var.aks_default_node_pool_node_count
    os_disk_type                = var.aks_default_node_pool_os_disk_type
    os_disk_size_gb             = var.aks_os_disk_size_gb
    type                        = var.aks_default_node_pool_type
    temporary_name_for_rotation = "${var.aks_default_node_pool_name}temp"
    tags                        = merge(var.tagging, var.extra_tags)

  }

  #Linux Profile
  linux_profile {
    admin_username = var.linux_admin_username
    ssh_key {
      key_data = var.ssh_public_key #file(var.ssh_public_key) 
    }
  }

  identity {
    type         = var.aks_umi_type
    identity_ids = tolist([var.aks_umi_ids])
  }

  # Network Profile
  network_profile {
    network_plugin = var.aks_network_profile_plugin
    dns_service_ip = var.aks_network_profile_dns_service_ip
    #docker_bridge_cidr = var.aks_network_profile_docker_bridge_cidr
    service_cidr = var.aks_network_profile_service_cidr
    #load_balancer_sku = var.aks_network_profile_lb_sku
  }

  oms_agent {
    msi_auth_for_monitoring_enabled = var.oms_agent.enabled
    log_analytics_workspace_id      = coalesce(var.oms_agent.log_analytics_workspace_id, var.log_analytics_workspace_id)
  }

  monitor_metrics {
    /* annotations_allowed = var.monitor_metrics.annotations_allowed
    labels_allowed      = var.monitor_metrics.labels_allowed*/
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  azure_active_directory_role_based_access_control {
    # managed                = true
    admin_group_object_ids = var.admin_group_object_ids #[azuread_group.aks_administrators.object_id]
    azure_rbac_enabled     = true
  }


  tags = merge(var.tagging, var.extra_tags)
  lifecycle {
    ignore_changes = [
      #kubernetes_version,
      windows_profile,
      #default_node_pool,
      default_node_pool[0].upgrade_settings,
      microsoft_defender,
      #linux_profile[0].ssh_key,
      tags
    ]
  }
}


module "diagnostic_settings" {
  count                      = var.aks_diagnostic_active ? 1 : 0
  source                     = "../diagnostic_setting"
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_kubernetes_cluster.aks_cluster.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_logs            = var.aks_diagnostic_logs
  diagnostic_metric          = var.aks_diagnostic_metric
}
