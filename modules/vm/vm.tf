resource "azurerm_public_ip" "azure_terraform_ex1_publicip_firewall" {
  name                         = var.public_ip_name_firewall
  location                     = var.location
  resource_group_name          = var.rg_name
  allocation_method            = "Static"
  sku                          = "Standard"

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_firewall" "azure_terraform_ex1_firewall" {
  name                = var.firewall_name
  location            = azurerm_public_ip.azure_terraform_ex1_publicip_firewall.location
  resource_group_name = azurerm_public_ip.azure_terraform_ex1_publicip_firewall.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_sbnt_id
    public_ip_address_id = azurerm_public_ip.azure_terraform_ex1_publicip_firewall.id
  }
}

resource "azurerm_public_ip" "azure_terraform_ex1_publicip_lb" {
  name                         = var.public_ip_name_lb
  location                     = var.location
  resource_group_name          = var.rg_name
  allocation_method            = "Static"

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_lb" "azure_terraform_ex1_lb" {
  name                = var.lb_name
  location            = azurerm_public_ip.azure_terraform_ex1_publicip_lb.location
  resource_group_name = azurerm_public_ip.azure_terraform_ex1_publicip_lb.resource_group_name

  frontend_ip_configuration {
    name                 = var.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.azure_terraform_ex1_publicip_lb.id
  }
}

resource "azurerm_lb_probe" "azure_terraform_ex1_lb_probe" {
  resource_group_name = azurerm_public_ip.azure_terraform_ex1_publicip_lb.resource_group_name
  loadbalancer_id     = azurerm_lb.azure_terraform_ex1_lb.id
  name                = "ssh-running-probe"
  port                = 80
}

resource "azurerm_lb_backend_address_pool" "azure_terraform_ex1_lb_backend_address_pool" {
  resource_group_name = azurerm_public_ip.azure_terraform_ex1_publicip_lb.resource_group_name
  loadbalancer_id     = azurerm_lb.azure_terraform_ex1_lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "azure_terraform_ex1_lb_rule" {
  resource_group_name            = azurerm_public_ip.azure_terraform_ex1_publicip_lb.resource_group_name
  loadbalancer_id                = azurerm_lb.azure_terraform_ex1_lb.id
  name                           = var.lb_rule_name
  protocol                       = var.lb_rule_protocol
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.frontend_ip_name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.azure_terraform_ex1_lb_backend_address_pool.id
  probe_id                       = azurerm_lb_probe.azure_terraform_ex1_lb_probe.id
}

resource "azurerm_network_security_group" "azure_terraform_ex1_nsg" {
  name                = var.nsg_name
  location            = azurerm_public_ip.azure_terraform_ex1_publicip_lb.location
  resource_group_name = azurerm_public_ip.azure_terraform_ex1_publicip_lb.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "MySQL"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3306
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_public_ip" "azure_terraform_ex1_publicip_vm" {
  count               = var.vm_count
  name                = "VMPublicIP${count.index}"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
   
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_network_interface" "azure_terraform_ex1_nic" {
  count               = var.vm_count
  name                = "${var.nic_name}${count.index}"
  location            = azurerm_public_ip.azure_terraform_ex1_publicip_vm[count.index].location
  resource_group_name = azurerm_public_ip.azure_terraform_ex1_publicip_vm[count.index].resource_group_name

  ip_configuration {
    name                          = "vm_ip_config${count.index}"
    subnet_id                     = var.sbnt_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.private_ip_vm, count.index)
    public_ip_address_id          = azurerm_public_ip.azure_terraform_ex1_publicip_vm[count.index].id
  }

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_availability_set" "azure_terraform_ex1_avset" {
  name                         = var.avset_name
  location                     = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name          = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_interface_security_group_association" "azure_terraform_ex1_nic_nsg_ass" {
  count                     = var.vm_count
  network_security_group_id = azurerm_network_security_group.azure_terraform_ex1_nsg.id
  network_interface_id      = element(azurerm_network_interface.azure_terraform_ex1_nic.*.id, count.index)

}

resource "random_id" "randomId" {
  keepers = {
    resource_group = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
  }
    
  byte_length = 8
}

resource "azurerm_storage_account" "azure_terraform_ex1_strg" {
  name                        = "azex1${random_id.randomId.hex}"
  resource_group_name         = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
  location                    = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  account_tier                = var.storage_acc_tier
  account_replication_type    = var.storage_acc_reptype

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "azure_terraform_ex1_vm" {
  count                 = var.vm_count
  name                  = "${var.vm_name}${count.index}"
  availability_set_id   = azurerm_availability_set.azure_terraform_ex1_avset.id
  location              = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name   = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
  network_interface_ids = [element(azurerm_network_interface.azure_terraform_ex1_nic.*.id, count.index)]
  size                  = var.vm_size

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    storage_account_type = var.storage_acc_type
  }

  computer_name  = "linuxvm${count.index}"
  admin_username = "einfochips"
  disable_password_authentication = true
        
  admin_ssh_key {
    username       = "einfochips"
    public_key     = tls_private_key.ssh_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.azure_terraform_ex1_strg.primary_blob_endpoint
  }

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

/*resource "time_sleep" "wait_180_seconds" {
  depends_on = [azurerm_linux_virtual_machine.azure_terraform_ex1_vm]
  create_duration = "3m"
}*/

resource "null_resource" "configuration" {
  depends_on = [azurerm_linux_virtual_machine.azure_terraform_ex1_vm, azurerm_public_ip.azure_terraform_ex1_publicip_vm]
  count      = var.vm_count
//  depends_on = [time_sleep.wait_180_seconds]

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.azure_terraform_ex1_publicip_vm[count.index].ip_address//element(azurerm_public_ip.azure_terraform_ex1_publicip_vm.*.ip_address, count.index)
    user        = "einfochips"
    private_key = tls_private_key.ssh_key.private_key_pem
    timeout     = "2m"
    agent       = false
  }

  provisioner "file" {
    source      = "../modules/vm/drupal.sh"
    destination = "/tmp/drupal.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 777 /tmp/drupal.sh",
      "cd /tmp",
      "./drupal.sh ${var.mysql_server_name} ${var.mysql_server_user} ${var.mysql_server_pass} ${azurerm_public_ip.azure_terraform_ex1_publicip_lb.ip_address}",
      "sudo chmod 777 /etc/ssh/sshd_config",
      "echo 'Port ${var.ssh_port}' >> /etc/ssh/sshd_config",
      "sudo service sshd restart"
    ]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "azure_terraform_ex1_backend_pool_association" {
  count                   = var.vm_count 
  network_interface_id    = element(azurerm_network_interface.azure_terraform_ex1_nic.*.id, count.index)
  ip_configuration_name   = "vm_ip_config${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.azure_terraform_ex1_lb_backend_address_pool.id
}
