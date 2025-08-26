variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  default     = "westeurope" #"westeurope" #"northeurope"
  type        = string
}


variable "environment" {
  description = "environment"
  default     = "prod"
  type        = string
}
##acr

variable "dns_zone_resource_group_name" {
  description = "Specifies the name of RG acr zone"
  default     = "rg-tr-fis-glb-northeurope-smwu"
  type        = string
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "private_acr_dns_zone" {
  description = "Specifies the name of private acr zone"
  default     = "privatelink.azurecr.io"
  type        = string
}

variable "virtual_network_address_space" {
  description = "Specifies the address prefix of the Virtual Network"
  default     = ["185.21.4.0/23"]
  type        = list(string)
}

variable "virtual_network_subnet_priva_address_prefix" {
  description = "Specifies the address prefix of the PrivA subnet"
  default     = ["185.20.17.0/24"]
  type        = list(string)
}

variable "virtual_network_subnet_puba_address_prefix" {
  description = "Specifies the address prefix of the PubA subnet"
  default     = ["185.20.18.0/24"]
  type        = list(string)
}

variable "virtual_network_subnet_aks_address_prefix" {
  description = "Specifies the address prefix of the Aks subnet"
  default     = ["185.20.24.0/21"]
  type        = list(string)
}

# Activate Logs
variable "vnet_diagnostic_active" {
  default     = false
  description = "Azure Diagnostics for VNET"
  type        = bool
}

####K8S
variable "aks_version" {
  description = "Kubernetes version"
  default     = "1.33.2"
  type        = string
}

variable "aks_network_profile_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "10.2.0.10"
  type        = string
}

variable "aks_network_profile_docker_bridge_cidr" {
  description = "Specifies the Docker Bridge CIDR"
  default     = "172.17.0.1/16"
  type        = string
}

variable "aks_network_profile_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "10.2.0.0/24"
  type        = string
}

variable "aks_network_profile_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = ["azure", "kubenet", "Standard"]
  type        = list(string)
}

variable "owners_object_id" {
  description = "Owners Object Id"
  default     = "7ea58632-1096-4b2c-ab3f-b27e1905cc6c"
  type        = string
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "DEV"
    Owner       = "TR"
    CostCenter  = "IT"
    Application = "Node"
    BillingCode = "MS-AZR-12345"
  }
}
