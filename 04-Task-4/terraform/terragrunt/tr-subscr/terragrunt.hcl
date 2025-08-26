locals {
    #env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals  
    env_vars = read_terragrunt_config("env.hcl").locals
}

terraform {
#   source = "${get_path_to_repo_root()}/infrastructure//"
  source = "../../"
}



include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
    environment                                   = local.env_vars.environment
    location                                      = "northeurope"
    network_resource_group_name                   = "rg-tr-northeurope-1234"
    kv_resource_group_name                        = "ne-rg-tr-infr"
    resource_group_name                           = "rg-fis-task"
    # Tags
    tags = {
      Environment = "DEV"
      Owner       = "TR"
      CostCenter  = "IT"
      Application = "Node"
      BillingCode = "MS-AZR-12345"
    }
}