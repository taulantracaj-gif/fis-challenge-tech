locals {
    #env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals  
    env_vars = read_terragrunt_config("env.hcl").locals
}

terraform {
#   source = "${get_path_to_repo_root()}/infrastructure//"
  source = "../../terraform" #"${get_parent_terragrunt_dir()}"
}


include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
    environment                                   = local.env_vars.environment
    docker_image_repository                       = "testtr.azurecr.io/01-node-app1"
    image_tag                                     = "latest"
    node_selector_value                           = "app-wildcard"
    domain                                        = "wildcard.mk"
    appgw_ssl_certificate_name                    = "wildcardcert"
    resource_group_name                           = local.env_vars.resource_group_name
    cluster_name                                  = local.env_vars.cluster_name
    namespace                                     = "fis-test"
    hostname_prefix                               = "nodeapp"
    APP_NAME                                      = "nodeapp"
    replica_count                                 = 2
    max_replicas                                  = 4
    target_cpu_utilization                        = 80
    target_memory_utilization                     = 70
}