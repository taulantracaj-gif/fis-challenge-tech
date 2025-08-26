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


# App Gw Name
variable "appgw_name" {
  default     = "random"
  description = "This defines name of App Gw"
  type        = string
}


# App Gw Name
variable "waf_policy" {
  default     = null
  description = "This defines ID of WAF policy"
  type        = string
}

# App Gw zones
variable "appgw_zones" {
  description = "Application gateway's Zones to use"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# App Gw zones
variable "app_gw_identity_ids" {
  description = "Application gateway's Identity User"
  type        = list(string)
  default     = []
}

#List of waf policy _sku
#variable "waf_policy_sku" {
#  type = map 
#}

# APP GW Sku
variable "appgw_sku" {
  type = object({
    name     = string
    tier     = string
    capacity = string
  })
  description = "List of objects waf_policy_sku"
  default = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
}


# APP GW appgw_frontend_ports
variable "appgw_frontend_ports" {
  type = list(object({
    name = string
    port = string
  }))
  description = "List of frontend ports"
  default = [{
    name = "feport"
    port = 80
  }]
}

# App Gw frontend ip configuration name
variable "appgw_frontend_ip_configuration_name" {
  description = "Name of the appgw frontend ip configuration"
  type        = string
}

# App Gw Ip Allocation method
variable "appgw_public_id" {
  type        = string
  default     = "Static"
  description = "This Variable defines pulbic ip id"
}

# APP app_gw_http_listener
variable "app_gw_http_listener" {
  type = object({
    name               = string
    frontend_port_name = string
    protocol           = string
  })
  description = "Object app_gw_http_listener"
  default = {
    name               = "httplstn"
    frontend_port_name = "feport"
    protocol           = "Http"
  }
}

# APP appgw_ip_configuration_name
variable "appgw_ip_configuration_name" {
  description = "Name of the appgw gateway ip configuration"
  default     = "IPConfig"
  type        = string
}

# APP appg_gw_subnet_id
variable "appg_gw_subnet_id" {
  default     = "random"
  description = "Azure Subnet ID"
  type        = string
}

# APP appgw_backend_address_pool_name
variable "appgw_backend_address_pool_name" {
  type        = string
  default     = "BackendPool"
  description = "This Variable defines appgw ip backend pool"
}

# APP app_gw_backend_http_settings
variable "app_gw_backend_http_settings" {
  type = object({
    name                  = string
    cookie_based_affinity = string
    port                  = string
    protocol              = string
    request_timeout       = string

  })
  description = "Object app_gw_backend_http_settings"
  default = {
    name                  = "beap"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }
}


# APP app_gw_http_listener
variable "app_gw_request_routing_rule" {
  type = object({
    name      = string
    rule_type = string
    priority  = string
  })
  description = "Object app_gw_http_listener"
  default = {
    name      = "rqrt"
    rule_type = "Basic"
    priority  = 100
  }
}


# APPGW Activate Logs
variable "app_gw_diagnostic_active" {
  default     = "false"
  description = "Azure Diagnostics for APPGW"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "(Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent."
  type        = string
}

# Enable logs - diagnostic_logs
variable "app_gw_diagnostic_logs" {
  type = list(object({
    category = string
    retention_policy = object({
      enabled = bool
    })
  }))
  description = "List of objects for diagnostic settings"
  default     = []
}

# AEnable metrics - diagnostic_metric
variable "app_gw_diagnostic_metric" {
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
