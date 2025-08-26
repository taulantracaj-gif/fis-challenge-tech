# https://www.terraform.io/docs/configuration/variables.html
# Input Variables
# Output Values
# Local Values (Optional)

variable "subscription_id" {
  default = ""
}
variable "client_id" {
  default = ""
}
variable "client_secret" {
  default = ""
}
variable "tenant_id" {
  default = ""
}

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

# Azure AKS Environment Name
variable "environment" {
  default     = "tst"
  description = "This is Environment var"
  type        = string
}

# ACR name
variable "acr_name" {
  default     = "cr"
  description = "This defines ACR name"
  type        = string
}

# ACR SKU
variable "acr_sku" {
  description = "(Optional) The SKU name of the container registry. Possible values are Basic, Standard and Premium. Defaults to Basic"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether traffic from public networks is permitted. Defaults to true. Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

# Azure ACR name
variable "acrname" {
  default     = "neadins"
  description = "This defines acr name"
  type        = string
}

variable "admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled. Defaults to false."
  type        = string
  default     = false
}

variable "georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspac. Must be present if acr_diagnostic_active is true."
  type        = string
}

# ACR  Activate Logs
variable "acr_diagnostic_active" {
  default     = "false"
  description = "Azure Diagnostics for acr"
  type        = string
}

# ACR Enable logs - diagnostic_logs
variable "acr_diagnostic_logs" {
  type = list(object({
    category = string
    retention_policy = object({
      enabled = bool
    })
  }))
  description = "List of objects for diagnostic settings"
  default     = []
}

# ACR Enable metrics - aks_diagnostic_metric
variable "acr_diagnostic_metric" {
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

variable "tagging" {
  type = map(any)
}

variable "extra_tags" {
  description = "Extra tags to add on"
  type        = map(string)
  default     = {}
}
