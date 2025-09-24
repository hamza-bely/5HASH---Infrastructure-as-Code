 /*todo | Ressource          | Configuration principale                                               |
todo    | ------------------ | ---------------------------------------------------------------------- |
todo    | Resource Group DEV | Nom : `rg-taylorshift-dev`, Région : France Central                    |
todo    | Database DEV       | Stockage : 32 Go, Backup : 7 jours, SKU : B\_Standard\_B1ms            |
todo    | PrestaShop DEV     | CPU : 1, RAM : 1.5 Go, 1 réplique, connecté à la DB, utilise DockerHub |
*/

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "dev" {
  name     = "rg-taylorshift-dev"
  location = "francecentral"

  tags = {
    environment = "dev"
    project     = "taylor-shift-billetterie"
    managed_by  = "terraform"
  }
}

module "database_dev" {
  source = "../../modules/database"

  resource_group_name = azurerm_resource_group.dev.name
  location           = azurerm_resource_group.dev.location
  environment        = "dev"
  admin_user         = var.db_admin_user
  admin_password     = var.db_admin_password

  sku_name           = "B_Standard_B1ms"
  storage_size_gb    = 32
  backup_retention_days = 7
  geo_redundant_backup = false
}

module "prestashop_dev" {
  source = "../../modules/prestashop"

  resource_group_name = azurerm_resource_group.dev.name
  location           = azurerm_resource_group.dev.location
  environment        = "dev"

  db_host     = module.database_dev.db_host
  db_name     = module.database_dev.db_name
  db_user     = module.database_dev.db_user
  db_password = module.database_dev.db_password

  cpu_cores    = 1
  memory_gb    = 1.5
  replica_count = 1

  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
}