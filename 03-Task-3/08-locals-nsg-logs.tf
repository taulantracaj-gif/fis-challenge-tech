locals {
  network_securitygroup_logs = [
    {
      category = "NetworkSecurityGroupEvent"
      retention_policy = {
        enabled = false
      }
    },
    {
      category = "NetworkSecurityGroupRuleCounter"
      retention_policy = {
        enabled = false
      }
    }
  ]
}
