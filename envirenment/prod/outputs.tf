output "prestashop_dev_url" {
  description = "URL d'accès à PrestaShop DEV"
  value = module.prestashop_dev.prestashop_url
}

output "database_dev_host" {
  description = "Host de la base de données DEV"
  value = module.database_dev.db_host
}