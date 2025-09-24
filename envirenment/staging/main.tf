/*todo| Ressource              | Configuration principale                                                                 |
todo  | ---------------------- | ---------------------------------------------------------------------------------------- |
todo  | Resource Group STAGING | Nom : `rg-taylorshift-staging`, Région : France Central, Tags : environment = staging    |
todo  | Database STAGING       | SKU : `GP_Standard_D2s_v3`, Stockage : 128 Go, Backup : 14 jours, Geo-redondance activée |
todo  | PrestaShop STAGING     | CPU : 2 cœurs, RAM : 4 Go, 2 réplicas, DB depuis module database, DockerHub login        |
todo  | Load Balancer STAGING  | IP statique, SKU : Standard, Frontend configuré pour trafic staging                      |*/


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

resource "azurerm_resource_group" "staging" {
  name     = "rg-taylorshift-staging"
  location = "francecentral"

  tags = {
    environment = "staging"
    project     = "taylor-shift-billetterie"
    managed_by  = "terraform"
  }
}

module "database_staging" {
  source = "../../modules/database"

  resource_group_name = azurerm_resource_group.staging.name
  location           = azurerm_resource_group.staging.location
  environment        = "staging"
  admin_user         = var.db_admin_user
  admin_password     = var.db_admin_password
  sku_name           = "GP_Standard_D2s_v3"
  storage_size_gb    = 128
  backup_retention_days = 14
  geo_redundant_backup = true
}

module "prestashop_staging" {
  source = "../../modules/prestashop"

  resource_group_name = azurerm_resource_group.staging.name
  location           = azurerm_resource_group.staging.location
  environment        = "staging"

  db_host     = module.database_staging.db_host
  db_name     = module.database_staging.db_name
  db_user     = module.database_staging.db_user
  db_password = module.database_staging.db_password

  cpu_cores    = 2
  memory_gb    = 4
  replica_count = 2

  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
}

# Load Balancer
resource "azurerm_public_ip" "staging_lb" {
  name                = "pip-taylorshift-staging-lb"
  location            = azurerm_resource_group.staging.location
  resource_group_name = azurerm_resource_group.staging.name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_lb" "staging" {
  name                = "lb-taylorshift-staging"
  location            = azurerm_resource_group.staging.location
  resource_group_name = azurerm_resource_group.staging.name
  sku                = "Standard"

  frontend_ip_configuration {
    name                 = "staging-frontend"
    public_ip_address_id = azurerm_public_ip.staging_lb.id
  }
}