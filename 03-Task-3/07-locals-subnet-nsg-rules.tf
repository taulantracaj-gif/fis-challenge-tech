locals {
  network_rule_priva = [
    {
      name                   = "Allow_SubnetRanges_VNET"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefixes = [
        element(var.virtual_network_subnet_priva_address_prefix, 0),
        element(var.virtual_network_subnet_puba_address_prefix, 0),
        element(var.virtual_network_subnet_aks_address_prefix, 0)
      ]
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowLoadBalancerServiceTag"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllVNET"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
  ]
  network_rule_aks = [
    {
      name                   = "Allow_AKS_SubnetRanges_VNET"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefixes = [
        element(var.virtual_network_subnet_aks_address_prefix, 0)
      ]
      destination_address_prefix = "*"
    },
    {
      name                   = "Allow_Other_SubnetRanges_VNET"
      priority               = 101
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefixes = [
        element(var.virtual_network_subnet_priva_address_prefix, 0),
        element(var.virtual_network_subnet_puba_address_prefix, 0)
      ]
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowLoadBalancerServiceTag"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllVNET"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
  ]
  network_rule_pub = [
    {
      name              = "Allow_port_443_80_Inbound"
      priority          = 101
      direction         = "Inbound"
      access            = "Allow"
      protocol          = "Tcp"
      source_port_range = "*"
      destination_port_ranges = [
        "80",
        "443"
      ]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow_Internet_Incoming_Traffic"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "65200-65535"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowLoadBalancerServiceTag"
      priority                   = 103
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    },
    {
      name                   = "Allow_SubnetRanges_VNET"
      priority               = 104
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefixes = [
        element(var.virtual_network_subnet_priva_address_prefix, 0),
        element(var.virtual_network_subnet_puba_address_prefix, 0),
        element(var.virtual_network_subnet_aks_address_prefix, 0)
      ]
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllVNET"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
  ]
}
