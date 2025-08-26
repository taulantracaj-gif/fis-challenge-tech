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

# Subnet Name
variable "subnet_name" {
  default     = "random"
  description = "Azure Subnet Name"
  type        = string
}

# NSG  Name
variable "nsg_name" {
  default     = "random"
  description = "Azure NSG Name"
  type        = string
}

# Subnet ID
variable "subnet_id" {
  default     = "random"
  description = "Azure Subnet ID"
  type        = string
}

# Azure Resource Group Name
variable "resource_group_name" {
  default     = "ne-global-rg"
  description = "This defines RG name"
  type        = string
}


# Network Rule list
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

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
  type        = string
  default     = null
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 7
}

variable "tagging" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "extra_tags" {
  description = "Extra tags to add on"
  type        = map(string)
  default     = {}
}
