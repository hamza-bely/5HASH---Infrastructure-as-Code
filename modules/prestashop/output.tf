output "prestashop_url" {
  description = "URL d'accès à PrestaShop"
  value = "http://${azurerm_container_group.prestashop.fqdn}"
}

output "prestashop_fqdn" {
  description = "FQDN du container PrestaShop"
  value = azurerm_container_group.prestashop.fqdn
}
