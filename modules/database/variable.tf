variable "location" {
  default = "francecentral"
}
variable "resource_group_name" {}
variable "admin_user" {
  description = "Nom d'utilisateur administrateur pour la base de données"
  type        = string
}
variable "admin_password" {
  description = "Mot de passe administrateur pour la base de données"
  type        = string
  sensitive   = true
}
variable "sku_name" {
  default = "Standard_B1ms"
}
variable "environment" {
  default = "dev"
}
