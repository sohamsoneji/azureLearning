resource "azurerm_virtual_network" "azure_terraform_ex1_vnet" {
    name                = var.vnet_name
    address_space       = [var.vnet_range]
    location            = var.location
    resource_group_name = var.rg_name

    tags = {
        environment = var.environment
        owner       = var.owner
        project     = var.project
    }
}

resource "azurerm_subnet" "azure_terraform_ex1_subnet" {
    name                 = var.subnet_name
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.azure_terraform_ex1_vnet.name
    address_prefixes     = [var.subnet_range]
}

resource "azurerm_subnet" "azure_terraform_ex1_firewall_subnet" {
    name                 = "AzureFirewallSubnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.azure_terraform_ex1_vnet.name
    address_prefixes     = [var.firewall_subnet_range]
}