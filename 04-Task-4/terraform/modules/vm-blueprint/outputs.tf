output "vm_id" {
  description = "Map of VM IDs keyed by VM name"
  value       = { for k, vm in azurerm_linux_virtual_machine.vm_devops : k => vm.id }
}

output "vm_name" {
  description = "Map of VM names keyed by VM name"
  value       = { for k, vm in azurerm_linux_virtual_machine.vm_devops : k => vm.name }
}
