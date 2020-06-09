resource "azurerm_public_ip" "azure_terraform_ex1_publicip" {
    name                         = var.public_ip_name
    location                     = var.location
    resource_group_name          = var.rg_name
    allocation_method            = "Dynamic"

    tags = {
        environment = var.environment
    }
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
  name                = var.nic_name
  location            = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name

  ip_configuration {
    name                          = "ex1_ip_config"
    subnet_id                     = var.sbnt_id
    private_ip_address_allocation = var.private_ip
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface_security_group_association" "azure_terraform_ex1_nic_nsg_ass" {
    network_security_group_id = azurerm_network_security_group.azure_terraform_ex1_nsg.id
    network_interface_id      = azurerm_network_interface.azure_terraform_ex1_nic.id

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
  name                  = var.vm_name
  location              = azurerm_network_security_group.azure_terraform_ex1_nsg.location
  resource_group_name   = azurerm_network_security_group.azure_terraform_ex1_nsg.resource_group_name
  network_interface_ids = [azurerm_network_interface.azure_terraform_ex1_nic.id]
  size                  = var.vm_size

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    storage_account_type = var.storage_acc_type
  }

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
}