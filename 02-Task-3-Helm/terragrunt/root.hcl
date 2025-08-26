locals {
  environment_vars = read_terragrunt_config("env.hcl")

  # Extract the project name from the directory path - using the current directory's basename
  subscription_name = basename(get_terragrunt_dir())
  
  # Parse components similar to Bicep logic
  name_components = split("-", local.subscription_name)
  base_name = join("-", slice(local.name_components, 0, length(local.name_components) - 2))
  environment =  element(local.name_components, length(local.name_components) - 2)
  
  # Generate the storage account name
  stripped_name = replace(local.base_name, "-", "")
  trimmed_name = substr(local.stripped_name, 0, min(15, length(local.stripped_name)))
  
  # Create a unique key based on the project path
 #   state_key = "shared-${path_relative_to_include()}.tfstate"
}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "azurerm" {
      features {}
      subscription_id = "${local.environment_vars.locals.subscription_id}"
  
    }

    provider "random" {}

EOF
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_version = ">=1.0"
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
        random = {
          source  = "hashicorp/kubernetes"
          version = "~> 2.33.0"
        }
        helm = {
          source  = "hashicorp/helm"
          version = "~> 2.16.0"
        }
      }
    }
EOF
}

remote_state {
  backend = "azurerm"
  config = {
    resource_group_name = local.environment_vars.locals.state_resource_group_name
    # For production environment it's better to have a different storage account
    storage_account_name = local.environment_vars.locals.state_storage_account_name
    container_name       = local.environment_vars.locals.state_container_name
    key                  = "${path_relative_to_include()}/terraform.tfstate" #"${path_relative_to_include()}/terraform.tfstate"
    # use_msi              = true
    # client_id            = "611c7780-7508-4003-bf15-7b770f5ae74f"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# generate "backend" {
#   path = "backend.tf"
#   if_exists = "overwrite"
#   contents = <<EOF
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "${local.environment_vars.locals.state_resource_group_name}"
#     storage_account_name = "${local.environment_vars.locals.state_storage_account_name}"
#     container_name       = "${local.environment_vars.locals.state_container_name}"
#     key                  = "${path_relative_to_include()}/terraform.tfstate"

#     use_azuread_auth = true
#   }
# }
# EOF
# }