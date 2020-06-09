provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "azure_terraform_ex1_vnet" {
  source = "../modules/vnet"
  rg_name = var.rg_name
  location = var.location
  environment = var.environment
  vnet_name = var.vnet_name
  vnet_range = var.vnet_range
  subnet_name = var.subnet_name
  subnet_range = var.subnet_range
}

module "azure_terraform_ex1_vm" {
  source = "../modules/vm"
  public_ip_name = var.public_ip_name
  firewall_name = var.firewall_name
  ssh_port = var.ssh_port
  location = var.location
  nsg_name = var.nsg_name
  nic_name = var.nic_name
  vm_name = var.vm_name
  vm_size = var.vm_size
  frontend_ip_name = var.frontend_ip_name
  lb_name = var.lb_name
  lb_rule_name = var.lb_rule_name
  lb_rule_protocol = var.lb_rule_protocol
  vm_count = var.vm_count
  managed_disk_size_gb = var.managed_disk_size_gb
  avset_name = var.avset_name
  storage_acc_type = var.storage_acc_type
  storage_acc_tier = var.storage_acc_tier
  storage_acc_reptype = var.storage_acc_reptype
  rg_name = var.rg_name
  sbnt_id = "${module.azure_terraform_ex1_vnet.subnet_id}"
  environment = var.environment
}

module "azure_terraform_ex1_mysql" {
  source = "../modules/mysql"
  rg_name = var.rg_name
  location = var.location
  mysql_server_name = var.mysql_server_name
  mysql_db_name = var.mysql_db_name
}

module "azure_terraform_ex1_dashboard" {
  source = "../modules/dashboard"
  storage_acc_name = var.storage_acc_name
  vm_count = var.vm_count
  rg_name = var.rg_name
  kv_name = var.kv_name
  mds_name = var.mds_name
  email_id = var.email_id
  mma_name = var.mma_name
  vmid = "${module.azure_terraform_ex1_vm.vm_id}"
  storageaccid = "${module.azure_terraform_ex1_vm.storage_acc_id}"
  mysqlserverid = "${module.azure_terraform_ex1_mysql.mysql_server_id}"
  lbid = "${module.azure_terraform_ex1_vm.lb_id}"
}
