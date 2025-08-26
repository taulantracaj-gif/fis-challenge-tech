locals {
  environment_vars = read_terragrunt_config("env.hcl")
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
          source  = "hashicorp/random"
          version = "~> 3.0"
        }
      }
    }
EOF
}

remote_state {
  backend = "azurerm"
  config = {
    resource_group_name = local.environment_vars.locals.state_resource_group_name
    storage_account_name = local.environment_vars.locals.state_storage_account_name
    container_name       = local.environment_vars.locals.state_container_name
    key                  = "${path_relative_to_include()}/terraform-vms.tfstate" 
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}