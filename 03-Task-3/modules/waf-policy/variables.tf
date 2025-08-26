# https://www.terraform.io/docs/configuration/variables.html
# Input Variables
# Output Values
# Local Values (Optional)

# Public WAF Policy Name
variable "waf_policy_name" {
  default     = "random"
  description = "Azure WAF Policy Name"
  type        = string
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

# Azure Waf Mode
variable "waf_mode" {
  default     = "Prevention"
  description = "Azure waf policy mode, possible values:Detection, Prevention"
  type        = string
}

#List of waf policy settings
variable "waf_policy_settings" {
  type = map(any)
}

# WAF exlusions
variable "waf_exclusions" {
  description = "A list used to configured WAF exclusions if defined"
  type        = list(map(string))
  default     = []
}

variable "waf_rule_group_override" {
  type = list(object({
    rule_group_name          = string
    rule_group_override_rule = list(map(string))
    #rules           = list(string)
  }))
  description = "List of objects including rule groups to disable"
  default     = []
}

# WAF exlusions
variable "waf_custom_rules_333" {
  description = "A list used to configured WAF exclusions if defined"
  type        = list(map(string))
  default     = []
}

# WAF custom rules
variable "waf_custom_rules" {
  #type =  list(map(string))
  #default     = [] 
  type = list(object({
    name      = string
    priority  = string
    rule_type = string
    match_conditions = list(object({
      match_variables = object({
        variable_name = string
        selector      = optional(string)
      })
      operator           = string
      negation_condition = string
      transforms         = optional(list(string)) #["Lowercase", "Trim"]
      match_values       = list(string)
    }))
    action = string
  }))
  description = "List of objects including custom rules"
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
