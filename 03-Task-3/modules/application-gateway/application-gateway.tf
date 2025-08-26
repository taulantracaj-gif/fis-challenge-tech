
#Create App Gw
resource "azurerm_application_gateway" "app_gw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group_name
  location            = var.location
  firewall_policy_id  = can(var.waf_policy) ? var.waf_policy : null
  zones               = var.appgw_zones

  identity {
    type         = "UserAssigned"
    identity_ids = var.app_gw_identity_ids
  }

  sku {
    name     = var.appgw_sku.name
    tier     = var.appgw_sku.tier
    capacity = var.appgw_sku.capacity
  }

  gateway_ip_configuration {
    name      = var.appgw_ip_configuration_name
    subnet_id = var.appg_gw_subnet_id
  }

  dynamic "frontend_port" {
    for_each = var.appgw_frontend_ports
    content {
      name = lookup(frontend_port.value, "name")
      port = lookup(frontend_port.value, "port")
    }
  }

  frontend_ip_configuration {
    name                 = var.appgw_frontend_ip_configuration_name
    public_ip_address_id = var.appgw_public_id
  }

  backend_address_pool {
    name = var.appgw_backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.app_gw_backend_http_settings.name
    cookie_based_affinity = var.app_gw_backend_http_settings.cookie_based_affinity
    port                  = var.app_gw_backend_http_settings.port
    protocol              = var.app_gw_backend_http_settings.protocol
    request_timeout       = var.app_gw_backend_http_settings.request_timeout
  }

  http_listener {
    name                           = var.app_gw_http_listener.name
    frontend_ip_configuration_name = var.appgw_frontend_ip_configuration_name
    frontend_port_name             = var.app_gw_http_listener.frontend_port_name
    protocol                       = var.app_gw_http_listener.protocol
  }

  # Request routing rule

  request_routing_rule {
    name                       = var.app_gw_request_routing_rule.name
    rule_type                  = var.app_gw_request_routing_rule.rule_type
    http_listener_name         = var.app_gw_http_listener.name
    backend_address_pool_name  = var.appgw_backend_address_pool_name
    backend_http_settings_name = var.app_gw_backend_http_settings.name
    priority                   = var.app_gw_request_routing_rule.priority
  }

  # Add Tags
  tags = merge(var.tagging, var.extra_tags)

  lifecycle {
    ignore_changes = [
      frontend_port,
      url_path_map,
      frontend_ip_configuration,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      redirect_configuration,
      ssl_certificate,
      probe,
      tags
    ]
  }
}

module "diagnostic_settings" {
  count                      = var.app_gw_diagnostic_active ? 1 : 0
  source                     = "../diagnostic_setting"
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_application_gateway.app_gw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_logs            = var.app_gw_diagnostic_logs
  diagnostic_metric          = var.app_gw_diagnostic_metric
}
