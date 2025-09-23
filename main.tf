provider "azurerm" {
  features {


  }
      subscription_id = "98986790-05f9-4237-b612-4814a09270dd"

  # Configuration pour Azure for Students
  # L'ID de subscription sera lu depuis la variable d'environnement ARM_SUBSCRIPTION_ID
  # ou automatiquement détecté via Azure CLI
  //subscription_id = "eb10ec54-cd75-4a07-89a3-cc597b358808"
  # Nouvelle propriété recommandée au lieu de skip_provider_registration
  resource_provider_registrations = "none"
}

provider "random" {
  # Provider pour générer des chaînes aléatoires
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

# Outputs pour les informations de connexion
output "database_connection_info" {
  description = "Informations de connexion à la base de données"
  value = {
    host     = module.database.db_host
    database = module.database.db_name
    username = module.database.db_user
    server_name = module.database.server_name
  }
}

output "database_password" {
  description = "Mot de passe de la base de données (sensible)"
  value = module.database.db_password
  sensitive = true
}

output "prestashop_url" {
  description = "URL d'accès à PrestaShop"
  value = "http://${module.prestashop.prestashop_fqdn}"
}