resource "azurerm_public_ip" "azure_terraform_ex1_publicip" {
  name                         = var.public_ip_name
  location                     = var.location
  resource_group_name          = var.rg_name
  allocation_method            = "Dynamic"
  sku                          = "Standard"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_firewall" "example" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.sbnt_id
    public_ip_address_id = azurerm_public_ip.azure_terraform_ex1_publicip.id
  }
}

resource "azurerm_lb" "azure_terraform_ex1_lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.rg_name

  frontend_ip_configuration {
    name                 = var.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.azure_terraform_ex1_publicip.id
  }
}

resource "azurerm_lb_rule" "azure_terraform_ex1_lb_rule" {
  resource_group_name            = var.rg_name
  loadbalancer_id                = azurerm_lb.azure_terraform_ex1_lb.id
  name                           = var.lb_rule_name
  protocol                       = var.lb_rule_protocol
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = var.frontend_ip_name
}

resource "azurerm_lb_backend_address_pool" "azure_terraform_ex1_lb_backend_address_pool" {
  resource_group_name = var.rg_name
  loadbalancer_id     = azurerm_lb.azure_terraform_ex1_lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_security_group" "azure_terraform_ex1_nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "azure_terraform_ex1_nic" {
  count               = var.vm_count
  name                = "${var.nic_name}${count.index}"
  location            = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name

  ip_configuration {
    name                          = "ex1_ip_config"
    subnet_id                     = var.sbnt_id
    private_ip_address_allocation = "dynamic"
  }

  tags = {
    environment = var.environment
  }
}

/*resource "azurerm_managed_disk" "azure_terraform_ex1_managed_disk" {
  count                = var.vm_count
  name                 = "datadisk_${count.index}"
  location             = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name  = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
  storage_account_type = var.storage_acc_type
  create_option        = "Empty"
  disk_size_gb         = var.managed_disk_size_gb
}*/

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

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "azure_terraform_ex1_storageaccount" {
    name                        = "azure_terraform_ex1${random_id.randomId.hex}"
    resource_group_name         = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
    location                    = azurerm_network_security_group.azure_terraform_ex1_nsg.location
    account_tier                = var.storage_acc_tier
    account_replication_type    = var.storage_acc_reptype

    tags = {
        environment = var.environment
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

  # Optional data disks
/*  data_disk {
    name              = "datadisk_new_${count.index}"
    managed_disk_type = var.storage_acc_type
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = var.managed_disk_size_gb
  }

  data_disk {
    name            = element(azurerm_managed_disk.azure_terraform_ex1_managed_disk.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.azure_terraform_ex1_managed_disk.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.azure_terraform_ex1_managed_disk.*.disk_size_gb, count.index)
  }*/

  computer_name  = "linuxvm"
  admin_username = "einfochips"
  disable_password_authentication = true
        
  admin_ssh_key {
    username       = "einfochips"
    public_key     = tls_private_key.ssh_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.azure_terraform_ex1_storageaccount.primary_blob_endpoint
  }

  tags = {
    environment = var.environment
  }

  provisioner "file" {
    source      = "drupal.sh"
    destination = "/tmp/drupal.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/drupal.sh",
      "./tmp/drupal.sh",
    ]
  }
}