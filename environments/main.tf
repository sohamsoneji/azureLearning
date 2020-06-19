provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "azure_terraform_ex1_rg" {
    name     = var.rg_name
    location = var.location

    tags = {
        environment = var.environment
        owner       = var.owner
        project     = var.project
    }
}

module "azure_terraform_ex1_vnet" {
  source       = "../modules/vnet"
  rg_name      = azurerm_resource_group.azure_terraform_ex1_rg.name
  location     = var.location
  environment  = var.environment
  owner        = var.owner
  project      = var.project
  vnet_name    = var.vnet_name
  vnet_range   = var.vnet_range
  subnet_name  = var.subnet_name
  subnet_range = var.subnet_range
  firewall_subnet_range = var.firewall_subnet_range
}

module "azure_terraform_ex1_mysql" {
  source = "../modules/mysql"
  rg_name           = azurerm_resource_group.azure_terraform_ex1_rg.name
  location          = var.location
  mysql_server_name = var.mysql_server_name
  mysql_server_user = var.mysql_server_user
  mysql_server_pass = var.mysql_server_pass
  mysql_db_name     = var.mysql_db_name
}

module "azure_terraform_ex1_vm" {
  source = "../modules/vm"
  public_ip_name_lb       = var.public_ip_name_lb
  public_ip_name_firewall = var.public_ip_name_firewall
  firewall_name           = var.firewall_name
  ssh_port                = var.ssh_port
  location                = var.location
  nsg_name                = var.nsg_name
  private_ip_vm           = var.private_ip_vm
  nic_name                = var.nic_name
  vm_name                 = var.vm_name
  vm_size                 = var.vm_size
  frontend_ip_name        = var.frontend_ip_name
  lb_name                 = var.lb_name
  lb_rule_name            = var.lb_rule_name
  lb_rule_protocol        = var.lb_rule_protocol
  vm_count                = var.vm_count
  managed_disk_size_gb    = var.managed_disk_size_gb
  avset_name              = var.avset_name
  storage_acc_type        = var.storage_acc_type
  storage_acc_tier        = var.storage_acc_tier
  storage_acc_reptype     = var.storage_acc_reptype
  rg_name                 = azurerm_resource_group.azure_terraform_ex1_rg.name
  sbnt_id                 = "${module.azure_terraform_ex1_vnet.subnet_id}"
  firewall_sbnt_id        = "${module.azure_terraform_ex1_vnet.firewall_sbnt_id}"
  mysql_server_name       = var.mysql_server_name
  mysql_server_user       = var.mysql_server_user
  mysql_server_pass       = var.mysql_server_pass
  environment             = var.environment
  owner                   = var.owner
  project                 = var.project
}

module "azure_terraform_ex1_dashboard" {
  source = "../modules/dashboard"
  storage_acc_name = var.storage_acc_name
  vm_count         = var.vm_count
  rg_name          = azurerm_resource_group.azure_terraform_ex1_rg.name
  kv_name          = var.kv_name
  mds_name_vm      = var.mds_name_vm
  mds_name_lb      = var.mds_name_lb
  mds_name_mysql   = var.mds_name_mysql
  email_id         = var.email_id
  mma_name_vm      = var.mma_name_vm
  mma_name_lb      = var.mma_name_lb
  mma_name_mysql   = var.mma_name_mysql
  vmid             = "${module.azure_terraform_ex1_vm.vm_id}"
  storageaccid     = "${module.azure_terraform_ex1_vm.storage_acc_id}"
  mysqlserverid    = "${module.azure_terraform_ex1_mysql.mysql_server_id}"
  lbid             = "${module.azure_terraform_ex1_vm.lb_id}"
}
