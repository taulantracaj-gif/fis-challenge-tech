locals {
  public_ip_configuration = {
    public_ip_allocation_method = "Static"
    public_ip_sku               = "Standard"
    zones                       = ["1", "2", "3"]
    log_analytics_workspace_id  = azurerm_log_analytics_workspace.loganalytic.id
  }
}
