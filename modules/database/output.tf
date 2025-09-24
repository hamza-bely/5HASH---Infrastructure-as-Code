output "db_host" {
  description = "FQDN du serveur de base de données"
  value = azurerm_mysql_flexible_server.db.fqdn
}

output "db_name" {
  description = "Nom de la base de données"
  value = azurerm_mysql_flexible_database.default.name
}

output "db_user" {
  description = "Nom d'utilisateur de la base de données"
  value = var.admin_user
}

output "db_password" {
  description = "Mot de passe de la base de données"
  value = var.admin_password
  sensitive = true
}

output "server_name" {
  description = "Nom du serveur MySQL"
  value = azurerm_mysql_flexible_server.db.name
}
