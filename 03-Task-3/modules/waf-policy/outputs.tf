# Create Outputs

# Azure WAF POLICY Name
output "waf_policy_name" {
  value = azurerm_web_application_firewall_policy.waf_policy.name
}

# Azure WAF POLICY ID
output "waf_policy_id" {
  value = azurerm_web_application_firewall_policy.waf_policy.id
}
