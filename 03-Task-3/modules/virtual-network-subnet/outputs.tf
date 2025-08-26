# Create Outputs

# Azure Subnet Name
output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

# Azure Subnet ID
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "virtual_network_subnets_nsg_output" {
  value = values(module.virtual_network_subnets_nsg).*
}
