# https://www.terraform.io/docs/configuration/variables.html
# Input Variables
# Output Values
# Local Values (Optional)

# Azure Location
variable "location" {
  default     = "North Europe"
  description = "Azure Region where all resources will be created"
  type        = string
}

# Azure Resource Group Name
variable "resource_group_name" {
  default     = "ne-global-rg"
  description = "This defines RG name"
  type        = string
}


# Azure kubernetes cluster
variable "aks_name" {
  default     = "ne-aks"
  description = "This defines AKS name"
  type        = string
}

# Azure kubernetes cluster DNS prefix
variable "aks_dns_prefix" {
  default     = "ne-aks-dns"
  description = "This defines AKS DNS prefix"
  type        = string
}

# Azure kubernetes cluster private_cluster_enabledx
variable "aks_private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

# Azure kubernetes cluster SKU tier
variable "aks_sku_tier" {
  default     = "Free"
  description = "This defines AKS SKU tier: Possible values: Free, Standard"
  type        = string
}

# Azure kubernetes cluster aks_workload_identity_enabled
variable "aks_workload_identity_enabled" {
  default     = false
  description = "Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false"
  type        = bool
}

# Azure kubernetes cluster aks_oidc_issuer_enabled
variable "aks_oidc_issuer_enabled" {
  default     = false
  description = "(Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
}

# Azure kubernetes cluster open_service_mesh_enabled
variable "aks_open_service_mesh_enabled" {
  default     = false
  description = "(Optional) Is Open Service Mesh enabled? For more details, please visit Open Service Mesh for AKS."
  type        = bool
}

# Azure kubernetes cluster aks_image_cleaner_enabled
variable "aks_image_cleaner_enabled" {
  description = "(Optional) Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = true
}

# Azure kubernetes cluster aks_azure_policy_enabled
variable "aks_azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = true
}

# Azure kubernetes cluster aks_http_application_routing_enabled
variable "aks_http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}

# Azure kubernetes cluster aks_role_based_access_control_enabled
variable "aks_role_based_access_control_enabled" {
  default     = true
  description = "This defines whether the role_based_access_control_enabled is enabled"
  type        = bool
}

# Azure kubernetes cluster aks_ingress_application_gateway
variable "aks_ingress_application_gateway" {
  description = "Specifies the Application Gateway Ingress Controller addon configuration."
  type = object({
    enabled      = bool
    gateway_id   = string
    gateway_name = string
    subnet_cidr  = string
    subnet_id    = string
  })
  default = {
    enabled      = false
    gateway_id   = null
    gateway_name = null
    subnet_cidr  = null
    subnet_id    = null
  }
}

# Azure kubernetes cluster appgwid
#variable "app_gw_id" {
#  description = "This defines id of appgw"
#  type        = string
#}

# Azure kubernetes cluster aks_default_node_pool_name
variable "aks_default_node_pool_name" {
  description = "Specifies the name of the default node pool"
  default     = "system"
  type        = string
}

# Azure kubernetes cluster orchestrator_version
variable "aks_version" {
  description = "(Optional) Version of Kubernetes.If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact patch version to be specified, minor version aliases such as 1.22 are also supported. - The minor version's latest GA patch is automatically chosen in that case. More details can be found in the documentation."
  default     = "1.26.6"
  type        = string
}

# Azure kubernetes cluster aks_default_node_pool_vm_size
variable "aks_default_node_pool_vm_size" {
  description = "Specifies the vm size of the default node pool"
  default     = "Standard_F8s_v2"
  type        = string
}

# Azure kubernetes cluster aks_vnet_subnet_id
variable "aks_vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
}

# Azure kubernetes cluster aks_default_node_pool_availability_zones
variable "aks_default_node_pool_availability_zones" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

# Azure kubernetes cluster aks_default_node_pool_node_labels
variable "aks_default_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

# Azure kubernetes cluster aks_default_node_pool_node_taints
variable "aks_default_node_pool_node_taints" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

# Azure kubernetes cluster default_node_pool_enable_auto_scaling
variable "aks_default_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

# Azure kubernetes cluster aks_default_node_pool_enable_host_encryption
variable "aks_default_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

# Azure kubernetes cluster aks_default_node_pool_enable_node_public_ip 
variable "aks_default_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

# Azure kubernetes cluster aks_default_node_pool_max_pods 
variable "aks_default_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

# Azure kubernetes cluster aks_default_node_pool_max_count 
variable "aks_default_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 3
}

# Azure kubernetes cluster aks_default_node_pool_min_count 
variable "aks_default_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 1
}

# Azure kubernetes cluster aks_default_node_pool_node_count 
variable "aks_default_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 1
}

# Azure kubernetes cluster aks_default_node_pool_os_disk_type 
variable "aks_default_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

# Azure kubernetes cluster aks_os_disk_size_gb 
variable "aks_os_disk_size_gb" {
  description = "(Optional) The size of the OS Disk which should be used for each agent in the Node Pool. temporary_name_for_rotation must be specified when attempting a change."
  type        = number
  default     = 60
}

# Azure kubernetes cluster aks_default_node_pool_os_disk_type 
variable "aks_default_node_pool_type" {
  description = "(Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets. Changing this forces a new resource to be created."
  type        = string
  default     = "VirtualMachineScaleSets"
}

# Azure kubernetes cluster linux_admin_username 
variable "linux_admin_username" {
  description = "(Required) Specifies the Admin Username for the AKS cluster worker nodes. Changing this forces a new resource to be created."
  type        = string
  default     = "azureuser"
}

# Azure kubernetes cluster ssh_public_key 
variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key used to access the cluster. Changing this forces a new resource to be created."
  type        = string
}

# Azure kubernetes cluster useridentity type
variable "aks_umi_type" {
  default     = "UserAssigned"
  description = "(Required) Specifies the type of Managed Service Identity that should be configured on this Kubernetes Cluster. Possible values are SystemAssigned or UserAssigned."
  type        = string
}

# Azure kubernetes cluster useridentity id
variable "aks_umi_ids" {
  description = " (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster."
  type        = string
}

# Azure kubernetes cluster aks_network_profile_plugin
variable "aks_network_profile_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}

# Azure kubernetes cluster aks_network_profile_plugin
variable "aks_network_profile_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "10.2.0.10"
  type        = string
}

# Azure kubernetes cluster aks_network_profile_plugin
variable "aks_network_profile_docker_bridge_cidr" {
  description = "Specifies the Docker Bridge CIDR"
  default     = "172.17.0.1/16"
  type        = string
}

# Azure kubernetes cluster aks_network_profile_service_cidr
variable "aks_network_profile_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "10.2.0.0/24"
  type        = string
}

# Azure kubernetes cluster aks_network_profile_service_cidr
variable "oms_agent" {
  description = "Specifies the OMS agent addon configuration."
  type = object({
    enabled                    = bool
    log_analytics_workspace_id = string
  })
  default = {
    enabled                    = true
    log_analytics_workspace_id = null
  }
}

# Azure kubernetes cluster aks_network_profile_service_cidr
variable "monitor_metrics" {
  description = " (Optional) Specifies a Prometheus add-on profile for the Kubernetes Cluster. A monitor_metrics block as defined below."
  type = object({
    annotations_allowed = string #  (Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric.   
    labels_allowed      = string # (Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric.
  })
  default = {
    annotations_allowed = null
    labels_allowed      = null
  }
}

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
  type        = string
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = []
  type        = list(string)
}

# AKS  Activate Logs
variable "aks_diagnostic_active" {
  default     = "false"
  description = "Azure Diagnostics for AKS"
  type        = string
}

# AKS Enable logs - diagnostic_logs
variable "aks_diagnostic_logs" {
  type = list(object({
    category = string
    retention_policy = object({
      enabled = bool
    })
  }))
  description = "List of objects for diagnostic settings"
  default     = []
}

# AKS Enable metrics - aks_diagnostic_metric
variable "aks_diagnostic_metric" {
  type = list(object({
    category = string
    enabled  = bool
    retention_policy = object({
      enabled = bool
    })
  }))
  description = "List of objects for diagnostic metrics"
  default     = []
}

# Azure Tags
variable "tagging" {
  type = map(any)
}

variable "extra_tags" {
  description = "Extra tags to add on"
  type        = map(string)
  default     = {}
}
