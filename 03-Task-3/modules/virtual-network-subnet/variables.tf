# https://www.terraform.io/docs/configuration/variables.html
# Input Variables
# Output Values
# Local Values (Optional)

# Subnet Name
variable "subnet_name" {
  default     = "random"
  description = "Azure Subnet Name"
  type        = string
}

# Azure Location
variable "location" {
  default     = "West Europe"
  description = "Azure Region where all resources will be created"
  type        = string
}

# Azure Resource Group Name
variable "resource_group_name" {
  default     = "ne-global-rg"
  description = "This defines RG name"
  type        = string
}


# Azure Virtual Network Name
variable "vnet_name" {
  default     = "random"
  description = "This defines name of VNET"
  type        = string
}

# Address Space
variable "address_range" {

}

variable "private_endpoint_network_policies_enabled" {
  description = "Enable or Disable network policies for the private endpoint on the subnet."
  type        = string
  default     = "Enabled"
}

variable "private_link_service_network_policies_enabled" {
  description = "Enable or Disable network policies for the private link service on the subnet."
  type        = bool
  default     = false
}

# Network Rules for NSG
variable "network_rule" {

}

# NSG  Rules active
variable "active" {
  default     = "false"
  description = "Azure apply NSG rules"
  type        = string
}

# NSG  Activate Logs
variable "diagnostic_active" {
  default     = "false"
  description = "Azure Diagnostics for NSG"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
  type        = string
  default     = null
}

# NSG Enable logs - diagnostic_logs
variable "nsg_diagnostic_logs" {
  type = list(object({
    category = string
    retention_policy = object({
      enabled = bool
    })
  }))
  description = "List of objects for diagnostic settings"
  default     = []
}
