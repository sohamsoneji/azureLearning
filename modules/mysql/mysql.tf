resource "azurerm_mysql_server" "azure_terraform_ex1_mysql_server" {
  name                = var.mysql_server_name
  location            = var.location
  resource_group_name = var.rg_name

  administrator_login          = "einfochips"
  administrator_login_password = "einfochips@123"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "azure_terraform_ex1_mysql_db" {
  name                = var.mysql_db_name
  resource_group_name = azurerm_mysql_server.azure_terraform_ex1_mysql_server.resource_group_name
  server_name         = azurerm_mysql_server.azure_terraform_ex1_mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}