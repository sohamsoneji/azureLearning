resource "azurerm_resource_group" "azure_terraform_ex1_rg" {
    name     = var.rg_name
    location = var.location

    tags = {
        environment = var.environment
    }
}

resource "azurerm_virtual_network" "azure_terraform_ex1_vnet" {
    name                = var.vnet_name
    address_space       = ["192.168.0.0/24"]
    location            = azurerm_resource_group.azure_terraform_ex1_rg.location
    resource_group_name = azurerm_resource_group.azure_terraform_ex1_rg.name

    tags = {
        environment = var.environment
    }
}

resource "azurerm_subnet" "azure_terraform_ex1_subnet" {
    name                 = var.subnet_name
    resource_group_name  = azurerm_resource_group.azure_terraform_ex1_rg.name
    virtual_network_name = azurerm_virtual_network.azure_terraform_ex1_vnet.name
    address_prefixes       = ["192.168.0.0/26"]
}