provider "azurerm" {
  features {}

  subscription_id = "eb10ec54-cd75-4a07-89a3-cc597b358808"
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

}

module "database" {
  source              = "./modules/database"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  admin_user          = var.db_user
  admin_password      = var.db_password
  environment         = var.environment
}

module "prestashop" {
  source              = "./modules/prestashop"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  db_host             = module.database.db_host
  db_name             = "prestashop"
  db_user             = var.db_user
  db_password         = var.db_password
  environment         = var.environment
}


