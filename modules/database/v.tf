variable "location" {
  default = "francecentral"
}
variable "resource_group_name" {}
variable "admin_user" {}
variable "admin_password" {}
variable "sku_name" {
  default = "Standard_B1ms"
}
variable "environment" {
  default = "dev"
}
