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


/*mysql_sku_name = "B_Standard_B1s"
mysql_storage_mb = 51200
mysql_backup_retention_days = 7*/