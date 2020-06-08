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
  subnet_name = var.subnet_name
}

module "azure_terraform_ex1_vm" {
  source = "../modules/vm"
  ssh_port = var.ssh_port
  location = var.location
  nsg_name = var.nsg_name
  nic_name = var.nic_name
  rg_name = var.rg_name
  subnet_id = "${module.azure_terraform_ex1_vnet.subnet_id}"
  environment = var.environment
}

module "my_dashboard" {
  source = "../modules/dashboard"
  storage_acc_name = var.storage_acc_name
  rg_name = var.rg_name
  kv_name = var.kv_name
  mds_name = var.mds_name
  email_id = var.email_id
  mma_name = var.mma_name
  vm_id = "${module.azure_terraform_ex1_vm.vm_id}"
}
