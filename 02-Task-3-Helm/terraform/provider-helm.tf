provider "helm" {
  alias = "aks"
  #   registry {
  #     url = "oci://adinsure.azurecr.io"
  #     username = var.helm_registry_username
  #     password = var.helm_registry_password
  #   }
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks_azure.kube_admin_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_azure.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_azure.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_azure.kube_admin_config.0.cluster_ca_certificate)
  }
}

data "azurerm_kubernetes_cluster" "aks_azure" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}
