locals {
    #env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals  
    env_vars = read_terragrunt_config("env.hcl").locals
}

terraform {
#   source = "${get_path_to_repo_root()}/infrastructure//"
  source = "../../" #"${get_parent_terragrunt_dir()}"
}



include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
    environment                                   = local.env_vars.environment
    location                                      = "westeurope"
    # ACR / DNS zone
    dns_zone_resource_group_name                  = "rg-tr-adins-glb-northeurope-smwu"
    private_acr_dns_zone                          = "privatelink.azurecr.io"
    acr_sku                                       = "Premium"
    # Networking
    virtual_network_address_space                 = ["185.21.4.0/23"]
    virtual_network_subnet_priva_address_prefix   = ["185.20.17.0/24"]
    virtual_network_subnet_puba_address_prefix    = ["185.20.18.0/24"]
    virtual_network_subnet_aks_address_prefix     = ["185.20.24.0/21"]
    # Diagnosticsd
    vnet_diagnostic_active                        = false

    # AKS cluster configuration
    aks_version                                   = "1.33.2"
    aks_network_profile_dns_service_ip            = "10.2.0.10"
    aks_network_profile_docker_bridge_cidr        = "172.17.0.1/16"
    aks_network_profile_service_cidr              = "10.2.0.0/24"
    aks_network_profile_plugin                    = ["azure", "kubenet", "Standard"]

    # Tags
    tags = {
      Environment = "DEV"
      Owner       = "TR"
      CostCenter  = "IT"
      Application = "Node"
      BillingCode = "MS-AZR-12345"
    }
}