#WAF Policy
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = var.waf_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge(var.tagging, var.extra_tags)


  dynamic "custom_rules" {
    for_each = var.waf_custom_rules != null ? var.waf_custom_rules : []
    content {
      name      = custom_rules.value.name
      priority  = custom_rules.value.priority
      rule_type = custom_rules.value.rule_type
      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions != null ? custom_rules.value.match_conditions : []
        content {
          match_variables {
            variable_name = can(match_conditions.value.match_variables.variable_name) ? match_conditions.value.match_variables.variable_name : null
            selector      = can(match_conditions.value.match_variables.selector) ? match_conditions.value.match_variables.selector : null
          }
          operator           = match_conditions.value.operator
          negation_condition = match_conditions.value.negation_condition
          transforms         = can(match_conditions.value.transforms) ? match_conditions.value.transforms : null
          match_values       = match_conditions.value.match_values
        }
      }
      action = custom_rules.value.action
    }
  }

  policy_settings {
    enabled                     = var.waf_policy_settings.enabled
    mode                        = var.waf_policy_settings.mode
    request_body_check          = var.waf_policy_settings.request_body_check
    file_upload_limit_in_mb     = var.waf_policy_settings.file_upload_limit_in_mb
    max_request_body_size_in_kb = var.waf_policy_settings.max_request_body_size_in_kb
  }

  managed_rules {
    dynamic "exclusion" {
      for_each = var.waf_exclusions
      content {
        match_variable          = lookup(exclusion.value, "match_variable")
        selector                = lookup(exclusion.value, "selector")
        selector_match_operator = lookup(exclusion.value, "selector_match_operator")
      }
    }
    managed_rule_set {
      type    = var.waf_policy_settings.type
      version = var.waf_policy_settings.version
      dynamic "rule_group_override" {
        for_each = var.waf_rule_group_override != null ? var.waf_rule_group_override : []
        content {
          rule_group_name = rule_group_override.value.rule_group_name
          dynamic "rule" {
            for_each = rule_group_override.value.rule_group_override_rule != null ? rule_group_override.value.rule_group_override_rule : []
            content {
              id      = can(rule.value.id) ? rule.value.id : null
              enabled = can(rule.value.enabled) ? rule.value.enabled : null
              action  = can(rule.value.action) ? rule.value.action : null
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      tags,
      custom_rules,
      managed_rules,
    ]
  }
}
