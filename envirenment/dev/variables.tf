variable "db_admin_user" {
  description = "Nom d'utilisateur administrateur pour la base de données"
  type        = string
  default     = "prestashop_admin"
}

variable "db_admin_password" {
  description = "Mot de passe administrateur pour la base de données"
  type        = string
  sensitive   = true
}

variable "dockerhub_username" {
  description = "Nom d'utilisateur Docker Hub"
  type        = string
  default     = "hampza"
}

variable "dockerhub_password" {
  description = "Mot de passe Docker Hub"
  type        = string
  sensitive   = true
  default     = "Bandello31!!!"
}