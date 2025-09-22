resource "azurerm_container_group" "prestashop" {
  name                = "prestashop-container"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  container {
    name   = "prestashop"
    image  = "prestashop/prestashop"
    cpu    = 1
    memory = 1.5

    environment_variables = {
      DB_SERVER = var.db_host
      DB_NAME   = var.db_name
      DB_USER   = var.db_user
      DB_PASSWD = var.db_password
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = "prestashop-${var.environment}"

  image_registry_credential {
    server   = "index.docker.io"
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
}
