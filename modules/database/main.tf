resource "random_string" "server_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_mysql_flexible_server" "db" {
  name                   = "mysql-prestashop-${var.environment}-${random_string.server_suffix.result}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.admin_user
  administrator_password = var.admin_password

  sku_name = var.sku_name
  version  = "8.0.21"

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup

  dynamic "high_availability" {
    for_each = var.high_availability ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  storage {
    size_gb = var.storage_size_gb
  }

  tags = {
    environment = var.environment
    project     = "taylor-shift-billetterie"
  }
}

resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  count               = var.environment == "prod" ? 0 : 1
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

resource "azurerm_mysql_flexible_server_firewall_rule" "dev_allow_all" {
  count               = var.environment == "dev" ? 1 : 0
  name                = "AllowAll"
  resource_group_name = azurerm_mysql_flexible_server.db.resource_group_name
  server_name         = azurerm_mysql_flexible_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "azure_services" {
  count               = var.environment != "dev" ? 1 : 0
  name                = "AllowAzureServices"
  resource_group_name = azurerm_mysql_flexible_server.db.resource_group_name
  server_name         = azurerm_mysql_flexible_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
