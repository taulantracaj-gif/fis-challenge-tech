locals {
  vm_map = { for vm in var.vms : vm.vm_name => vm }
}

resource "azapi_resource" "ssh_public_key" {
  for_each = local.vm_map

  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "ssh-${each.value.vm_name}"
  location  = each.value.location
  parent_id = each.value.resource_group_id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  for_each    = local.vm_map
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key[each.key].id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]

  lifecycle {
    ignore_changes = []
  }
}


resource "azurerm_key_vault_secret" "private_key" {
  for_each     = local.vm_map
  name         = "priv-key-${each.value.vm_name}"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  value        = azapi_resource_action.ssh_public_key_gen[each.key].output.privateKey

  tags = merge(each.value.tags, {
    ResourceType = "Secret",
    Name         = "priv-key-${each.value.vm_name}"
  })
}

# Create Network Interfaces per VM
resource "azurerm_network_interface" "nic" {
  for_each = local.vm_map

  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = each.value.ip_config_name
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(each.value.tags, each.value.extra_tags)

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Linux Virtual Machines per VM config
resource "azurerm_linux_virtual_machine" "vm_devops" {
  for_each = local.vm_map

  name                            = each.value.vm_name
  location                        = each.value.location
  resource_group_name             = each.value.resource_group_name
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = each.value.vm_size
  admin_username                  = each.value.vm_admin_username
  admin_password                  = each.value.disable_password_authentication ? null : each.value.vm_admin_password
  disable_password_authentication = each.value.disable_password_authentication
  source_image_id                 = each.value.enable_custom ? each.value.vm_source_custom_image_id : null
  encryption_at_host_enabled      = each.value.enable_encryption_at_host
  dynamic "admin_ssh_key" {
    for_each = each.value.disable_password_authentication ? [1] : []

    content {
      username   = each.value.vm_admin_username
      public_key = azapi_resource_action.ssh_public_key_gen[each.key].output.publicKey
    }
  }
  boot_diagnostics {
    storage_account_uri = null
  }

  dynamic "source_image_reference" {
    for_each = each.value.enable_custom ? [] : [1]

    content {
      publisher = each.value.vm_source_image_publisher
      offer     = each.value.vm_source_image_offer
      sku       = each.value.vm_source_image_sku
      version   = each.value.vm_source_image_version
    }
  }

  dynamic "identity" {
    for_each = each.value.identity_type

    content {
      type         = identity.value
      identity_ids = (endswith(identity.value, "UserAssigned") && contains(keys(each.value), "identity_ids")) ? each.value.identity_ids : null
    }
  }

  os_disk {
    name                 = each.value.storage_os_disk.name
    caching              = each.value.storage_os_disk.caching
    disk_size_gb         = each.value.storage_os_disk.disk_size_gb
    storage_account_type = each.value.storage_os_disk.os_type
  }

  tags = merge(each.value.tags, each.value.extra_tags)

  lifecycle {
    ignore_changes = [tags]
  }
}

# Optional Managed Disks per VM
resource "azurerm_managed_disk" "managed_disk" {
  for_each = { for vm in var.vms : vm.vm_name => vm if vm.enable_managed_disk }

  name                 = each.value.managed_disk_name
  location             = each.value.location
  resource_group_name  = each.value.resource_group_name
  storage_account_type = each.value.managed_disk.storage_account_type
  create_option        = each.value.managed_disk.create_option
  disk_size_gb         = each.value.managed_disk.disk_size_gb

  tags = merge(each.value.tags, { ResourceType = "Managed Disk" })

  lifecycle {
    ignore_changes = [tags, encryption_settings]
  }
}

# Attach Managed Disks to respective VMs
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment" {
  for_each = { for vm in var.vms : vm.vm_name => vm if vm.enable_managed_disk }

  managed_disk_id    = azurerm_managed_disk.managed_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm_devops[each.key].id
  lun                = each.value.managed_disk_attachment.lun
  caching            = each.value.managed_disk_attachment.caching
}
