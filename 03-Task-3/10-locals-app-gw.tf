locals {
  appg_frontend_port_name = "${azurerm_virtual_network.virtualnetwork.name}-feport"
  app_gw_configuration = {
    zones = ["1", "2", "3"]
    sku = {
      name     = "WAF_v2"
      tier     = "WAF_v2"
      capacity = 2
    }
    frontend_port = [
      {
        name = local.appg_frontend_port_name
        port = 80
      },
      {
        name = "httpsPort"
        port = 443
      }
    ]
    appgw_frontend_ip_configuration_name = "${azurerm_virtual_network.virtualnetwork.name}-feip"
    appgw_backend_address_pool_name      = "${azurerm_virtual_network.virtualnetwork.name}-beap"
    app_gw_backend_http_settings = {
      name                  = "${azurerm_virtual_network.virtualnetwork.name}-be-htst"
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 1
    }
    app_gw_http_listener = {
      name               = "${azurerm_virtual_network.virtualnetwork.name}-httplstn"
      frontend_port_name = local.appg_frontend_port_name
      protocol           = "Http"
    }
    app_gw_request_routing_rule = {
      name                      = "${azurerm_virtual_network.virtualnetwork.name}-rqrt"
      rule_type                 = "Basic"
      backend_address_pool_name = "${azurerm_virtual_network.virtualnetwork.name}-beap"
      priority                  = 100
    }
  }
  app_gw_configuration_logs = {
    diagnostic_active = true
    diagnostic_logs = [
      {
        category = "ApplicationGatewayAccessLog"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "ApplicationGatewayPerformanceLog"
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "ApplicationGatewayFirewallLog"
        retention_policy = {
          enabled = true
        }
      }
    ],
    diagnostic_metric = [
      {
        category = "AllMetrics"
        enabled  = true
        retention_policy = {
          enabled = true
        }
      }
    ]
  }
}
