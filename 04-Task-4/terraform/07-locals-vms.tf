locals {
  vm_definitions = [
    {
      vm_name                   = "vm-${local.org}-ubuntu-${local.loc}-001"
      location                  = var.location
      resource_group_name       = data.azurerm_resource_group.resource_group.name
      resource_group_id         = data.azurerm_resource_group.resource_group.id
      kv_resource_group_name    = var.kv_resource_group_name
      nic_name                  = "${module.naming.network_interface.name_unique}-001"
      ip_config_name            = "${module.naming.network_interface.name_unique}-ipConfig-001"
      subnet_id                 = data.azurerm_subnet.agent.id
      vm_size                   = "Standard_B1ms"
      enable_custom             = false
      enable_encryption_at_host = true
      vm_source_custom_image_id = "" #"/sharedGalleries/000-000-000-00-00-00/images/all_ub2204_x86_64_g2/versions/latest"
      identity_type             = ["SystemAssigned"]
      storage_os_disk = {
        name         = "osdisk01"
        caching      = "ReadWrite"
        disk_size_gb = 127
        os_type      = "Standard_LRS"
      }
      vm_admin_username               = "azureuser"
      vm_admin_password               = azurerm_key_vault_secret.vm_self_hosted_admin_password.value
      disable_password_authentication = true
      enable_managed_disk             = false
      #managed_disk_name                     = module.naming.managed_disk.name_unique 
      # managed_disk                          = {
      #   storage_account_type                = "Premium_LRS" #StandardSSD_LRS
      #   create_option                       = "Empty"
      #   disk_size_gb                        = 200
      # }
      # managed_disk_attachment               =  {
      #   lun                                 = 10
      #   caching                             = "ReadWrite"
      # } 
      vm_source_image_publisher = "Canonical"
      vm_source_image_offer     = "0001-com-ubuntu-server-jammy"
      vm_source_image_sku       = "22_04-lts"
      vm_source_image_version   = "latest"
      tags                      = var.tags
      extra_tags = {
        ResourceType = "Virtual Machine"
      }
    },
    {
      vm_name                   = "vm-${local.org}-redhat-${local.loc}-002"
      location                  = var.location
      resource_group_name       = data.azurerm_resource_group.resource_group.name
      resource_group_id         = data.azurerm_resource_group.resource_group.id
      kv_resource_group_name    = var.kv_resource_group_name
      nic_name                  = "${module.naming.network_interface.name_unique}-002"
      ip_config_name            = "${module.naming.network_interface.name_unique}-ipConfig-002"
      subnet_id                 = data.azurerm_subnet.agent.id
      vm_size                   = "Standard_B2ms"
      enable_custom             = false
      enable_encryption_at_host = true
      vm_source_custom_image_id = ""
      identity_type             = ["SystemAssigned"]
      storage_os_disk = {
        name         = "osdisk02"
        caching      = "ReadWrite"
        disk_size_gb = 64
        os_type      = "Standard_LRS"
      }
      vm_admin_username               = "azureuser"
      vm_admin_password               = azurerm_key_vault_secret.vm_self_hosted_admin_password.value
      disable_password_authentication = true
      enable_managed_disk             = false
      vm_source_image_publisher       = "RedHat"
      vm_source_image_offer           = "RHEL"
      vm_source_image_sku             = "9-lvm-gen2"
      vm_source_image_version         = "latest"
      tags                            = var.tags
      extra_tags = {
        ResourceType = "Virtual Machine Redhat"
      }
    },
    {
      vm_name                   = "vm-${local.org}-jumpbox-${local.loc}-003"
      location                  = var.location
      resource_group_name       = data.azurerm_resource_group.resource_group.name
      resource_group_id         = data.azurerm_resource_group.resource_group.id
      kv_resource_group_name    = var.kv_resource_group_name
      nic_name                  = "${module.naming.network_interface.name_unique}-003"
      ip_config_name            = "${module.naming.network_interface.name_unique}-ipConfig-003"
      subnet_id                 = data.azurerm_subnet.agent.id
      vm_size                   = "Standard_B2ms"
      enable_custom             = false
      enable_encryption_at_host = true
      vm_source_custom_image_id = ""
      identity_type             = ["SystemAssigned"]
      storage_os_disk = {
        name         = "osdiskjm03"
        caching      = "ReadWrite"
        disk_size_gb = 64
        os_type      = "Standard_LRS"
      }
      vm_admin_username               = "azureuser"
      vm_admin_password               = azurerm_key_vault_secret.vm_self_hosted_admin_password.value
      disable_password_authentication = true
      enable_managed_disk             = false
      vm_source_image_publisher       = "Canonical"
      vm_source_image_offer           = "0001-com-ubuntu-server-jammy"
      vm_source_image_sku             = "22_04-lts"
      vm_source_image_version         = "latest"
      tags                            = var.tags
      extra_tags = {
        ResourceType = "Virtual Machine Jumpbox"
      }
    }
  ]
}
