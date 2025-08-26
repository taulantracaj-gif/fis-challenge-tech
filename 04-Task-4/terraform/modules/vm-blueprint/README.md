# Azure Linux Virtual Machine (vm-linux) Terraform Module

## Table of Contents
- [Description](#description)
- [Features](#features)
- [Requirements](#requirements)
- [Variables](#variables)
- [Usage](#usage)
- [Outputs](#outputs)
- [Extension & Customization](#extension--customization)
- [Best Practices](#best-practices)
- [References](#references)
- [License](#license)

---

## Description

This Terraform module provisions multiple Azure Linux Virtual Machines with integrated NIC creation. It supports custom or marketplace images, managed data disks, managed identities, custom initialization scripts, DevOps agent registration, and secure configuration options. Designed for scalable deployments of production workloads, CI/CD agents, or general-purpose compute.

---

## Features

- Deploys multiple Linux VMs with configurable sizes, OS images, and admin credentials  
- Creates and associates one Network Interface per VM internally  
- Supports both marketplace and custom images  
- Optional managed data disk creation and attachment  
- Managed identities (SystemAssigned/UserAssigned)  
- OS disk encryption at host  
- Custom initialization via Azure VM Extension (package install, DevOps registration)  
- Secure password authentication options  
- Flexible tagging and governance  

---

## Requirements

- Terraform >= 1.0  
- AzureRM Provider >= 3.0  
- Appropriate Azure permissions for all resource types  
- (Optional) SAS URLs for custom scripts if using DevOps agent or custom packages  

---

## Variables

| Name                         | Type                      | Description                                               |
|------------------------------|---------------------------|-----------------------------------------------------------|
| `vms`                        | list(object)              | List of VM configurations including NIC and disk details |
| &nbsp;&nbsp;`vm_name`        | string                    | Name of the VM                                            |
| &nbsp;&nbsp;`location`       | string                    | Azure region                                             |
| &nbsp;&nbsp;`resource_group_name` | string              | Resource group name                                      |
| &nbsp;&nbsp;`nic_name`       | string                    | Network Interface name                                   |
| &nbsp;&nbsp;`ip_config_name` | string                    | NIC IP configuration name                                |
| &nbsp;&nbsp;`subnet_id`      | string                    | Subnet ID for the NIC                                    |
| &nbsp;&nbsp;`vm_size`        | string                    | VM size/SKU                                             |
| &nbsp;&nbsp;`vm_admin_username` | string                 | Admin username                                           |
| &nbsp;&nbsp;`vm_admin_password` | string                 | Admin password                                           |
| &nbsp;&nbsp;`disable_password_authentication` | bool         | Disable password authentication                          |
| &nbsp;&nbsp;`enable_custom`  | bool                      | Use custom image (if true)                               |
| &nbsp;&nbsp;`vm_source_custom_image_id` | optional(string)  | Custom image ID (required if `enable_custom` is true)   |
| &nbsp;&nbsp;`vm_source_image_publisher` | optional(string)   | Marketplace image publisher (if `enable_custom` false)  |
| &nbsp;&nbsp;`vm_source_image_offer` | optional(string)        | Marketplace image offer (if `enable_custom` false)      |
| &nbsp;&nbsp;`vm_source_image_sku` | optional(string)          | Marketplace image SKU (if `enable_custom` false)        |
| &nbsp;&nbsp;`vm_source_image_version` | optional(string)       | Marketplace image version (if `enable_custom` false)    |
| &nbsp;&nbsp;`identity_type`  | list(string)              | Managed identity type(s), e.g., ["SystemAssigned"]       |
| &nbsp;&nbsp;`identity_ids`   | optional(list(string))    | User-assigned identity IDs (if applicable)               |
| &nbsp;&nbsp;`storage_os_disk` | object                   | OS disk configuration (name, caching, size, type)        |
| &nbsp;&nbsp;`enable_encryption_at_host` | bool             | Enable OS disk encryption at host                         |
| &nbsp;&nbsp;`tags`           | map(string)               | Base tags                                                |
| &nbsp;&nbsp;`extra_tags`     | map(string)               | Additional tags                                         |
| &nbsp;&nbsp;`enable_managed_disk` | bool                  | Enable managed data disk                                 |
| &nbsp;&nbsp;`managed_disk_name` | optional(string)        | Managed disk name                                       |
| &nbsp;&nbsp;`managed_disk`   | optional(object)          | Managed disk config (storage type, create option, size) |
| &nbsp;&nbsp;`managed_disk_attachment` | optional(object)    | Managed disk attachment config (LUN, caching)            |
| &nbsp;&nbsp;`enable_packages_install` | bool               | Install packages via VM extension                        |
| &nbsp;&nbsp;`enable_devops_agent` | bool                 | Register DevOps agent via VM extension                   |
| &nbsp;&nbsp;`script_sas_url_packages` | string             | SAS URL for install_packages.sh script                   |
| &nbsp;&nbsp;`script_sas_url_extension` | string            | SAS URL for extension.sh script                          |

---

## Usage

```
locals {
vms = [
    {
    vm_name = "vm-example-01"
    location = "northeurope"
    resource_group_name = "my-rg"
    nic_name = "nic-example-01"
    ip_config_name = "ipconfig-example-01"
    subnet_id = data.azurerm_subnet.example.id
    vm_size = "Standard_B1ms"
    vm_admin_username = "azureuser"
    vm_admin_password = "P@ssw0rd123!"
    disable_password_authentication = false
    enable_custom = true
    vm_source_custom_image_id = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Compute/images/my-image"
    enable_encryption_at_host = true
    vm_source_image_publisher = ""
    vm_source_image_offer = ""
    vm_source_image_sku = ""
    vm_source_image_version = ""
    identity_type = ["SystemAssigned"]
    identity_ids = []
    storage_os_disk = {
    name         = "osdisk1"
    caching      = "ReadWrite"
    disk_size_gb = 128
    os_type      = "Standard_LRS"
    }

    tags                      = { environment = "dev" }
    extra_tags                = { owner = "devops" }

    enable_managed_disk       = false

    }
]
}


module "vm_linux_multi" {
source = "./modules/vm-linux"

vms = local.vms
}

```

---

## Outputs

| Output    | Description                         |
|-----------|-------------------------------------|
| `vm_id`   | Map of VM resource IDs keyed by VM name  |
| `vm_name` | Map of VM names keyed by VM name           |

---

## Extension & Customization

- Uses Azure VM Custom Script Extension to run post-deployment scripts like package installation and DevOps agent registration.  
- Supports managed identities for secure access.  
- Optionally attaches managed data disks.  
- Flexible tagging to support governance and cost management.  

---

## Best Practices

- Use Azure Key Vault or Terraform secrets for sensitive information like passwords and PAT tokens.  
- Prefer managed identities over static credentials where possible.  
- Rotate sensitive keys regularly.  
- Use custom images for consistent deployments.  
- Enable encryption at host for improved security.  
- Implement monitoring and logging setup using Azure Monitor.  

---

## References

- [Terraform azurerm_linux_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)  
- [Azure Linux VM documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform)  
- [Azure VM Custom Script Extension](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux)  
- [Terraform Azure VM Samples](https://github.com/Azure/terraform-azurerm-virtual-machine)  

---
