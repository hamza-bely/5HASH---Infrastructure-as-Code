variable "location" {}
variable "resource_group_name" {}
variable "db_host" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" {}
variable "environment" {
  default = "dev"
}

variable "dockerhub_username" {
  default = "hampza"
}
variable "dockerhub_password" {
  default = "Bandello31!!!"
}
