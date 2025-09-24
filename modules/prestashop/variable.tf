variable "location" {
  description = "La région Azure où déployer les ressources"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources Azure"
  type        = string
}

variable "db_host" {
  description = "Adresse du serveur de base de données"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
}

variable "db_user" {
  description = "Nom d'utilisateur pour la base de données"
  type        = string
}

variable "db_password" {
  description = "Mot de passe pour la base de données"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "dockerhub_username" {
  description = "Nom d'utilisateur DockerHub"
  type        = string
}

variable "dockerhub_password" {
  description = "Mot de passe DockerHub"
  type        = string
  sensitive   = true
}

variable "cpu_cores" {
  description = "Nombre de cœurs CPU alloués au conteneur"
  type        = number
  default     = 2
}

variable "memory_gb" {
  description = "Mémoire en Go allouée au conteneur"
  type        = number
  default     = 4
}
