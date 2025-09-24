resource "random_string" "container_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_container_group" "prestashop" {
  name                = "prestashop-${var.environment}-${random_string.container_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  container {
    name   = "prestashop"
    image  = "prestashop/prestashop:latest"
    cpu    = var.cpu_cores
    memory = var.memory_gb

    environment_variables = {
      DB_SERVER = var.db_host
      DB_NAME   = var.db_name
      DB_USER   = var.db_user
      DB_PASSWD = var.db_password
      PS_DOMAIN = var.environment == "prod" ? "taylorshift.com" : "${var.environment}.taylorshift.com"
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = "prestashop-${var.environment}-${random_string.container_suffix.result}"

  image_registry_credential {
    server   = "index.docker.io"
    username = var.dockerhub_username
    password = var.dockerhub_password
  }

  restart_policy = var.environment == "prod" ? "Always" : "OnFailure"

  tags = {
    environment = var.environment
    project     = "taylor-shift-billetterie"
  }
}
