locals {
  waf_configuration = {
    policy_settings = {
      enabled                     = true
      mode                        = "Prevention"
      request_body_check          = true
      file_upload_limit_in_mb     = 100
      max_request_body_size_in_kb = 128
      type                        = "OWASP"
      version                     = "3.2"
    }
    rule_group_override = [
      /*
       {
         rule_group_name          = "REQUEST-920-PROTOCOL-ENFORCEMENT"
         #rules                    = ["920420", "920320", "920330"]
         rule_group_override_rule = [
          {
            id      = "920420"
            enabled = false 
            #action  = "Block" # https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=drs21#anomaly-scoring false (Optional) Describes the override action to be applied when rule matches. Possible values are Allow, AnomalyScoring, Block and Log.
          },
          {
            id      = "920320"
            enabled = false
            #action  = "Block" # https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=drs21#anomaly-scoring (Optional) Describes the override action to be applied when rule matches. Possible values are Allow, AnomalyScoring, Block and Log.
          },
          {
            id      = "920330"
            enabled = false
            #action  = "Block" # https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=drs21#anomaly-scoring (Optional) Describes the override action to be applied when rule matches. Possible values are Allow, AnomalyScoring, Block and Log.
          }
         ]
       }*/
    ]
    exclusion = [
      /*
       {
         match_variable          = "RequestArgNames"
         selector                = "picture"
         selector_match_operator = "Equals"
       },
       {
         match_variable          = "RequestHeaderNames"
         selector                = "x-company-secret-header"
         selector_match_operator = "Equals"
       },
       {
         match_variable          = "RequestCookieNames"
         selector                = "too-tasty"
         selector_match_operator = "EndsWith"
       }*/
    ]
  }
  waf_custom_rules = {
    rules = [/*
       {
         name             = "Rule1"
         priority         = 1
         rule_type        = "MatchRule"
         match_conditions = [
          {
            match_variables = {
              variable_name = "RemoteAddr"
            }
            operator           = "IPMatch"
            negation_condition = false
            match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
          }
         ]
         action = "Block"
       },
       {
         name             = "RequestArgNames"
         priority         = 2
         rule_type        = "MatchRule"
         match_conditions = [
          {
            match_variables = {
              variable_name = "RequestHeaders"
              selector      = "UserAgent"
            }
            operator           = "Contains"
            negation_condition = false
            transforms    = ["Lowercase", "Trim"]
            match_values       = ["Windows"]
          }
         ]
         action = "Block"
       },
       {
         name             = "Rule3"
         priority         = 3
         rule_type        = "MatchRule"
         match_conditions = [
          {
            match_variables = {
              variable_name = "RemoteAddr"
            }
            operator           = "IPMatch"
            negation_condition = false
            match_values       = ["192.168.1.0/24"]
          },
          {
            match_variables = {
              variable_name = "RequestHeaders"
              selector      = "UserAgent"
            }
            operator           = "Contains"
            negation_condition = false
            match_values       = ["Windows"]
          }
         ]
         action = "Block"
       }*/
    ]
  }
}
