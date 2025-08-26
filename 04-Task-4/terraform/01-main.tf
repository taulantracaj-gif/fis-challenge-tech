

module "naming" {
  source                 = "Azure/naming/azurerm"
  suffix                 = ["${local.org}", "${local.prj}", "${local.env}", "${local.ord}"]
  unique-include-numbers = true
  unique-length          = 4
}


resource "random_password" "vm_self_hosted_admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-=+[]{}<>?" # Excludes "_"
  lower            = true
  upper            = true
  numeric          = true
}

###Create secret for admin-user-sql###
resource "azurerm_key_vault_secret" "vm_self_hosted_admin_password" {
  name         = "vm-self-hosted-password"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  value        = random_password.vm_self_hosted_admin_password.result
  tags         = { ResourceType = "Secret", Name = "vm-self-hosted-password" }
}


module "multi_vm" {
  source = ".//modules/vm-blueprint"

  vms = local.vm_definitions
}
