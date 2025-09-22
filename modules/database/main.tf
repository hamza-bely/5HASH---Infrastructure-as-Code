resource "random_string" "server_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_mysql_flexible_server" "db" {
  name                   = "prestashop-db-${var.environment}-${random_string.server_suffix.result}"
  location               = "francecentral"
  resource_group_name    = var.resource_group_name
  administrator_login    = var.admin_user
  administrator_password = var.admin_password
  sku_name = "B_Standard_B1ms"
  version                = "8.0.21"

  # Configuration SSL pour autoriser les connexions non sécurisées
  # ATTENTION: En production, utilisez toujours SSL !
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  
  storage {
    size_gb = 32
  }

  tags = {
    environment = var.environment
  }
}

# Configuration pour désactiver require_secure_transport
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.db.name
  value               = "OFF"
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