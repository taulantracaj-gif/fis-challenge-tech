locals {
  acr_configuration = {
    diagnostic_active = false
    diagnostic_logs = [
      {
        category = "ContainerRegistryRepositoryEvents"
        retention_policy = {
          enabled = false
        }
      },
      {
        category = "ContainerRegistryLoginEvents"
        retention_policy = {
          enabled = false
        }
      }
    ],
    diagnostic_metric = [
      {
        category = "AllMetrics"
        enabled  = false
        retention_policy = {
          enabled = false
        }
      }
    ]
  }
}
