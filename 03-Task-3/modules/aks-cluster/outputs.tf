# Create Outputs

# Azure aks_name
output "aks_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.id
  description = "Specifies the resource id of the AKS cluster."
}

output "kubelet_identity_object_id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
  description = "Specifies the object id of the kubelet identity of the AKS cluster."
}

output "agic_managed_identity_object_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.ingress_application_gateway[0].ingress_application_gateway_identity.0.object_id
}


output "key_vault_managed_identity_object_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity.0.object_id
}

/*
output "kubelet_identity_object_id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
  sensitive = true
  description = "Specifies the object id of the kubelet identity of the AKS cluster."
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
  description = "Contains the Kubernetes config to be used by kubectl and other compatible tools."
}

output "private_fqdn" {
  value       = azurerm_kubernetes_cluster.aks_cluster.private_fqdn
  sensitive   = true
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster."
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  description = "Specifies the resource id of the auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}*/
