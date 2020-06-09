variable "rg_name" {
    type = string
}

variable "location" {
    type = string
}

variable "environment" {
    type = string
}

variable "vnet_name" {
    type = string
}

variable "vnet_range" {
    type = string
}

variable "subnet_name" {
    type = string
}

variable "subnet_range" {
    type = string
}

variable "public_ip_name" {
  type = string
}

variable "firewall_name" {
  type = string
}

variable "ssh_port" {
    type = number
}

variable "nsg_name" {
    type = string
}

variable "nic_name" {
    type = string
}

variable "storage_acc_name" {
    type = string
}

variable "storage_acc_tier" {
  type = string
}

variable "storage_acc_reptype" {
  type = string
}

variable "kv_name" {
    type = string
}

variable "vm_name" {
    type = string
}

variable "vm_size" {
  type = string
}

variable "frontend_ip_name" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "lb_rule_name" {
  type = string
}

variable "lb_rule_protocol" {
  type = string
}

variable "vm_count" {
  type = number
}

variable "managed_disk_size_gb" {
  type = number
}

variable "avset_name" {
  type = string
}

variable "storage_acc_type" {
  type = string
}

variable "mysql_server_name" {
    type = string
}

variable "mysql_db_name" {
    type = string
}

variable "mds_name" {
    type = string
}

variable "email_id" {
    type = string
}

variable "mma_name" {
    type = string
}

