variable "public_ip_name_lb" {
  type = string
}

variable "public_ip_name_firewall" {
  type = string
}

variable "firewall_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
    type = string
}

variable "project" {
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

variable "private_ip_vm" {
  type = list
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

variable "storage_acc_type" {
  type = string
}

variable "storage_acc_tier" {
  type = string
}

variable "storage_acc_reptype" {
  type = string
}

variable "sbnt_id" {
  
}

variable "firewall_sbnt_id" {
  
}

variable "mysql_server_name" {
    type = string
}

variable "mysql_server_user" {
    type = string
}

variable "mysql_server_pass" {
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

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

