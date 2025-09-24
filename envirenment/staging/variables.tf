variable "db_admin_user" {
  description = "Nom d'utilisateur administrateur pour la base de données"
  type        = string
}

variable "db_admin_password" {
  description = "Mot de passe administrateur pour la base de données"
  type        = string
  sensitive   = true
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
