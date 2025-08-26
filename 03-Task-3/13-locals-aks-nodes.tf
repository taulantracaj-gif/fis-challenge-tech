locals {
  aks_node_configuration = {
    kubernetes_cluster_id = module.aks_cluster.aks_id
    name                  = "linuxds8"
    vm_size               = "Standard_D8s_v5"
    mode                  = "User"
    node_labels = {
      "nodepool-type" = "User"
      "environment"   = "${local.env}"
      "nodepool"      = "Linux"
      "app"           = "${local.org}-${local.prj}"
    }
    zones                  = ["1", "2", "3"]
    vnet_subnet_id         = module.virtual_network_subnets["virtual_network_subnet_aks"].subnet_id
    enable_auto_scaling    = true
    enable_host_encryption = true
    enable_node_public_ip  = false
    orchestrator_version   = var.aks_version
    max_pods               = 50
    max_count              = 3
    min_count              = 1
    node_count             = 1
    os_disk_size_gb        = 60
    os_disk_type           = "Managed"
    os_type                = "Linux"
    priority               = "Regular"
  }
  aks_node_configuration_server = {
    kubernetes_cluster_id = module.aks_cluster.aks_id
    name                  = "linuxsrv"
    vm_size               = "Standard_E4as_v5"
    mode                  = "User"
    node_labels = {
      "nodepool-type" = "User"
      "environment"   = "${local.env}"
      "nodepool"      = "Linux"
      "app"           = "${local.org}-${local.prj}-server"
    }
    zones                  = ["1", "2", "3"]
    vnet_subnet_id         = module.virtual_network_subnets["virtual_network_subnet_aks"].subnet_id
    enable_auto_scaling    = true
    enable_host_encryption = true
    enable_node_public_ip  = false
    orchestrator_version   = var.aks_version
    max_pods               = 50
    max_count              = 3
    min_count              = 1
    node_count             = 1
    os_disk_size_gb        = 60
    os_disk_type           = "Managed"
    os_type                = "Linux"
    priority               = "Regular"
  }
}
