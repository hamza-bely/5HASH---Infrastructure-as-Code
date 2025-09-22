variable "location" {
  default = "francecentral"
}
variable "resource_group_name" {}
variable "admin_user" {
  default = "hamzauser"
}
variable "admin_password" {
  default = "hamzapassword"

}
variable "sku_name" {
  default = "Standard_B1ms"
}
variable "environment" {
  default = "dev"
}
