output "tls_private_key" { 
  value = tls_private_key.ssh_key[*].private_key_pem
}

output "vm_id" {
//  value = element(azurerm_linux_virtual_machine.azure_terraform_ex1_vm.*.id, count.index)
  value = azurerm_linux_virtual_machine.azure_terraform_ex1_vm[*].id
}

output "storage_acc_id" {
  value = azurerm_storage_account.azure_terraform_ex1_strg.id
}

output "lb_id" {
  value = azurerm_lb.azure_terraform_ex1_lb.id
}