resource "azurerm_mysql_flexible_server" "db" {
  name                   = "prestashop-db-${var.environment}"
  location               = "francecentral"
  resource_group_name    = var.resource_group_name
  administrator_login    = var.admin_user
  administrator_password = var.admin_password
  sku_name = "B_Standard_B1ms"
  version                = "8.0.21"

  storage {
    size_gb = 32
  }

  tags = {
    environment = var.environment
  }
}


resource "azurerm_mysql_flexible_database" "default" {
  name                = "prestashop"
  resource_group_name = azurerm_mysql_flexible_server.db.resource_group_name
  server_name         = azurerm_mysql_flexible_server.db.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  name                = "AllowAll"
  resource_group_name = azurerm_mysql_flexible_server.db.resource_group_name
  server_name         = azurerm_mysql_flexible_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}



/*mysql_sku_name = "B_Standard_B1s"
mysql_storage_mb = 51200
mysql_backup_retention_days = 7*/