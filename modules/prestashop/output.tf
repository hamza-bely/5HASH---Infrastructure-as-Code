output "prestashop_url" {
  value = "http://${azurerm_container_group.prestashop.fqdn}"
}
