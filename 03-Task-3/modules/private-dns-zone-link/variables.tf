variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the private dns zone"
  type        = string
}

variable "name" {
  description = "(Required) The name of the Private DNS Zone Virtual Network Link. Changing this forces a new resource to be created."
  type        = string
}

variable "private_dns_zone" {
  description = " (Required) The name of the Private DNS zone (without a terminating dot). Changing this forces a new resource to be created."
  type        = string
}

variable "virtual_network_id" {
  description = "(Required) The ID of the Virtual Network that should be linked to the DNS Zone. Changing this forces a new resource to be created."
  type        = string
}


variable "tags" {
  description = "(Optional) Specifies the tags of the private dns zone"
  default     = {}
}

/*
variable "private_dns_zone" {
  description = "(Required) The name of the Private DNS zone (without a terminating dot). Changing this forces a new resource to be created."
  type        = string
}*/
