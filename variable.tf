variable "location" {
  description = "La région Azure où déployer les ressources"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources Azure"
  type        = string
  default     = "taylor-shift-rg"
}

variable "db_user" {
  description = "Nom d'utilisateur pour la base de données"
  type        = string
  default     = "adminuser"
}

variable "db_password" {
  description = "Mot de passe pour la base de données"
  type        = string
  sensitive   = true
  default     = "Password123!"
}

variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
  default     = "dev"
}
