/*todo| Ressource                     | Configuration principale                                                                                              |
todo  | ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
todo  |  Resource Group PROD           | Nom : `rg-taylorshift-prod`, Région : France Central, Tags : environment = prod, critical = high                      |
todo  |  Database PROD                 | SKU : `GP_Standard_D4s_v3`, Stockage : 512 Go, Backup : 35 jours, Geo-redondance activée, Haute disponibilité activée |
todo  |  PrestaShop PROD               | CPU : 4 cœurs, RAM : 8 Go, 5 réplicas, DB depuis module database, DockerHub login                                     |
todo  |  Container Apps PROD           | Auto-scaling : min 3 → max 50 réplicas, sécurisation, logs                                                            |
todo  |  Application Gateway PROD      | Load Balancer niveau 7 (WAF\_v2), HTTPS, auto-scaling min 3 → max 50, règles WAF OWASP                                |
todo  |  Virtual Network & Subnet PROD | Réseau privé pour PROD                                                                                                |
todo  |  Public IP PROD                | IP statique pour gateway                                                                                              |
todo  |  Monitoring & Alerts PROD      | Email & SMS pour alertes critiques                                                                                   | */



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

resource "azurerm_resource_group" "prod" {
  name     = "rg-taylorshift-prod"
  location = "France Central"

  tags = {
    environment = "prod"
    project     = "taylor-shift-billetterie"
    managed_by  = "terraform"
    critical    = "high"
  }
}

module "database_prod" {
  source = "../../modules/database"

  resource_group_name = azurerm_resource_group.prod.name
  location           = azurerm_resource_group.prod.location
  environment        = "prod"
  admin_user         = var.db_admin_user
  admin_password     = var.db_admin_password

  sku_name           = "GP_Standard_D4s_v3"
  storage_size_gb    = 512
  backup_retention_days = 35
  geo_redundant_backup = true
  high_availability = true
}

module "prestashop_prod" {
  source = "../../modules/prestashop"

  resource_group_name = azurerm_resource_group.prod.name
  location           = azurerm_resource_group.prod.location
  environment        = "prod"

  # Configuration base de données
  db_host     = module.database_prod.db_host
  db_name     = module.database_prod.db_name
  db_user     = module.database_prod.db_user
  db_password = module.database_prod.db_password

  cpu_cores    = 4
  memory_gb    = 8
  replica_count = 5

  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
}

resource "azurerm_container_app_environment" "prod" {
  name                = "cae-taylorshift-prod"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.prod.id
}

resource "azurerm_log_analytics_workspace" "prod" {
  name                = "law-taylorshift-prod"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app" "prestashop_prod" {
  name                         = "ca-prestashop-prod"
  container_app_environment_id = azurerm_container_app_environment.prod.id
  resource_group_name          = azurerm_resource_group.prod.name
  revision_mode               = "Single"

  template {
    min_replicas = 3
    max_replicas = 50

    container {
      name   = "prestashop"
      image  = "prestashop/prestashop:latest"
      cpu    = 2
      memory = "4Gi"

      env {
        name  = "DB_SERVER"
        value = module.database_prod.db_host
      }

      env {
        name  = "DB_NAME"
        value = module.database_prod.db_name
      }

      env {
        name  = "DB_USER"
        value = module.database_prod.db_user
      }

      env {
        name        = "DB_PASSWD"
        secret_name = "db-password"
      }
    }
  }

  secret {
    name  = "db-password"
    value = module.database_prod.db_password
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = true
    target_port              = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Application Gateway pour PROD (Load Balancer de niveau 7)
resource "azurerm_virtual_network" "prod" {
  name                = "vnet-taylorshift-prod"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "prod_gateway" {
  name                 = "subnet-gateway"
  resource_group_name  = azurerm_resource_group.prod.name
  virtual_network_name = azurerm_virtual_network.prod.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "prod_gateway" {
  name                = "pip-taylorshift-prod-gateway"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_application_gateway" "prod" {
  name                = "ag-taylorshift-prod"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 10
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.prod_gateway.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_port {
    name = "frontend-port-https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.prod_gateway.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-settings"
    priority                   = 1
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  # Auto-scaling
  autoscale_configuration {
    min_capacity = 3
    max_capacity = 50
  }
}

# Monitoring et alertes pour PROD
resource "azurerm_monitor_action_group" "prod_alerts" {
  name                = "ag-taylorshift-prod-alerts"
  resource_group_name = azurerm_resource_group.prod.name
  short_name          = "prodAlert"

  email_receiver {
    name          = "admin-team"
    email_address = "admin@taylorshift-agency.com"
  }

  sms_receiver {
    name         = "emergency"
    country_code = "33"
    phone_number = "0123456789"
  }
}