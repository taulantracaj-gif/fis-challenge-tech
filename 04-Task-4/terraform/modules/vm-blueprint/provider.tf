terraform {
  # 1. Required Version Terraform
  required_version = "~> 1.0"
  # 2. Required Terraform Providers
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.5"
    }
  }
}
