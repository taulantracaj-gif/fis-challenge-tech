locals {
  aks_configuration = {
    aks_name                             = module.naming.kubernetes_cluster.name_unique
    zones                                = ["1", "2", "3"]
    aks_private_cluster_enabled          = false
    aks_sku_tier                         = "Standard"
    aks_workload_identity_enabled        = false
    aks_oidc_issuer_enabled              = false
    aks_open_service_mesh_enabled        = false
    aks_image_cleaner_enabled            = true
    aks_azure_policy_enabled             = true
    aks_http_application_routing_enabled = false
    aks_ingress_application_gateway = {
      enabled      = true
      gateway_id   = module.appgw.app_gw_id
      gateway_name = null
      subnet_cidr  = null
      subnet_id    = null
    }
    aks_role_based_access_control_enabled = true
    aks_default_node_pool = {
      aks_default_node_pool_name    = "system"
      aks_default_node_pool_vm_size = "Standard_F8s_v2"
      aks_default_node_pool_node_labels = {
        "nodepool-type" = "system"
        "environment"   = "${local.env}"
        "nodepool"      = "linux"
        "app"           = "system-apps"
      }
      aks_default_node_pool_node_taints            = ["sku=gpu:NoSchedule"]
      aks_default_node_pool_enable_auto_scaling    = true
      aks_default_node_pool_enable_host_encryption = true
      aks_default_node_pool_enable_node_public_ip  = false
      aks_default_node_pool_max_pods               = 50
      aks_default_node_pool_max_count              = 3
      aks_default_node_pool_min_count              = 1
      aks_default_node_pool_node_count             = 1
      aks_default_node_pool_os_disk_type           = "Ephemeral"
      aks_os_disk_size_gb                          = 60
      aks_default_node_pool_type                   = "VirtualMachineScaleSets"
    }
    aks_linux_profile = {
      linux_admin_username = "azureuser"
      ssh_public_key       = azapi_resource_action.ssh_public_key_gen_newest.output.publicKey
    }
    aks_identity = {
      aks_umi_type = "UserAssigned"
    }
    aks_network_profile = {
      aks_network_profile_plugin             = element(var.aks_network_profile_plugin, 0)
      aks_network_profile_dns_service_ip     = var.aks_network_profile_dns_service_ip
      aks_network_profile_docker_bridge_cidr = var.aks_network_profile_docker_bridge_cidr
      aks_network_profile_service_cidr       = var.aks_network_profile_service_cidr
    }
    aks_oms_agent = {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalytic.id
    }
    monitor_metrics = {
      annotations_allowed = null
      labels_allowed      = null
    }
    log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalytic.id
  }
  aks_configuration_logs = {
    diagnostic_active = false
    diagnostic_logs = [
      {
        category = "kube-apiserver"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "kube-audit-admin"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "kube-scheduler"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "cluster-autoscaler"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "guard"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "cloud-controller-manager"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "kube-controller-manager"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "csi-azuredisk-controller"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "csi-azurefile-controller"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "csi-snapshot-controller"
        retention_policy = {
          enabled = true
        }
      }
    ],
    diagnostic_metric = [
      {
        category = "AllMetrics"
        enabled  = true
        retention_policy = {
          enabled = true
        }
      }
    ]
  }
}
