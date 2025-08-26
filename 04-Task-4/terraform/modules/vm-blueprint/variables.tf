variable "vms" {
  description = "List of VM configurations with NIC info"
  type = list(object({
    vm_name             = string
    location            = string
    resource_group_name = string
    resource_group_id   = string

    # NIC related
    nic_name       = string
    ip_config_name = string
    subnet_id      = string

    vm_size                         = string
    vm_admin_username               = string
    vm_admin_password               = string
    disable_password_authentication = bool
    enable_custom                   = bool
    vm_source_custom_image_id       = optional(string)
    vm_source_image_publisher       = optional(string)
    vm_source_image_offer           = optional(string)
    vm_source_image_sku             = optional(string)
    vm_source_image_version         = optional(string)
    identity_type                   = list(string)
    identity_ids                    = optional(list(string))
    storage_os_disk = object({
      name         = string
      caching      = string
      disk_size_gb = number
      os_type      = string
    })
    enable_encryption_at_host = bool
    tags                      = map(string)
    extra_tags                = map(string)

    enable_managed_disk = bool
    managed_disk_name   = optional(string)
    managed_disk = optional(object({
      storage_account_type = string
      create_option        = string
      disk_size_gb         = number
    }))
    managed_disk_attachment = optional(object({
      lun     = number
      caching = string
    }))
  }))
}


variable "kv_resource_group_name" {
  description = "Specifies the global resource group name"
  default     = "ne-rg-tr-infr"
  type        = string
}
