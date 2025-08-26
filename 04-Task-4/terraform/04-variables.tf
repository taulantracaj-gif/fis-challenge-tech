variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  default     = "northeurope" #"westeurope" #"northeurope"
  type        = string
}

variable "environment" {
  description = "environment"
  default     = "test"
  type        = string
}

variable "network_resource_group_name" {
  description = "Specifies the name of global networking resource group (for private endpoints, NSGs, etc.)"
  default     = "rg-tr-northeurope-1234"
  type        = string

}

variable "kv_resource_group_name" {
  description = "Specifies the global resource group name"
  default     = "ne-rg-tr-infr"
  type        = string
}


variable "resource_group_name" {
  description = "Specifies the global resource group name"
  default     = "ne-rg-vm-infr"
  type        = string
}

# Tags
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
