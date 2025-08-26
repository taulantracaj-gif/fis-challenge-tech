

output "vm_prod" {
  value = values(module.multi_vm).*
}
