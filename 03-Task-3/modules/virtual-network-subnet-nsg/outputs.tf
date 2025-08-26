# Create Outputs

# Azure NSG Name
/*
output "nsg_name" {
  value = var.active ? azurerm_network_security_group.azure-nsg[0].name : null
}

# Azure NSG ASS ID
output "nsg_ass_subnet_id" {
  value = var.active ? azurerm_subnet_network_security_group_association.nsg-ass-subnet[0].id : null
}
*/
output "nsg_name" {
  value = var.active ? (
    length(azurerm_network_security_group.azure-nsg) > 0 ?
    azurerm_network_security_group.azure-nsg[0].name : null
  ) : null
}

output "nsg_ass_subnet_id" {
  value = var.active ? (
    length(azurerm_subnet_network_security_group_association.nsg-ass-subnet) > 0 ?
    azurerm_subnet_network_security_group_association.nsg-ass-subnet[0].id : null
  ) : null
}
