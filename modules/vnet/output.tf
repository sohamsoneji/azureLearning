output "subnet_id" {
  value = azurerm_subnet.azure_terraform_ex1_subnet.id
}

output "firewall_sbnt_id" {
  value = azurerm_subnet.azure_terraform_ex1_firewall_subnet.id
}
