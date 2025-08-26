# Create Outputs
# Azure AD Group Id
output "azure_ad_group_id" {
  value = azuread_group.az_ad_group.id
}

# Azure AD Group Object Id
output "azure_ad_group_objectid" {
  value = azuread_group.az_ad_group.object_id
}
