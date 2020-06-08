resource "azurerm_network_security_group" "azure_terraform_ex1_nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
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
  name                = var.nic_name
  location            = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name

  ip_configuration {
    name                          = "ex1_ip_config"
    subnet_id                     = var.sbnt_id
    private_ip_address_allocation = "192.168.0.50"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface_security_group_association" "azure_terraform_ex1_nic_nsg_ass" {
    network_security_group_id = azurerm_network_security_group.azure_terraform_ex1_nsg.id
    network_interface_id      = azurerm_network_interface.azure_terraform_ex1_nic.id

}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "azure_terraform_ex1_vm" {
  name                  = var.vm_name
  location              = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name   = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
  network_interface_ids = [azurerm_network_interface.azure_terraform_ex1_nic.id]
  size               = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "linuxvm"
  admin_username = "einfochips"
  disable_password_authentication = true
        
  admin_ssh_key {
    username       = "einfochips"
    public_key     = tls_private_key.ssh_key.public_key_openssh
  }

  tags = {
    environment = var.environment
  }
}