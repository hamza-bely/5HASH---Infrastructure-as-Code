variable "location" {
  description = "Localisation Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
}

variable "admin_user" {
  description = "Nom d'utilisateur administrateur"
  type        = string
}

variable "admin_password" {
  description = "Mot de passe administrateur"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SKU de la base de données"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_size_gb" {
  description = "Taille du stockage en GB"
  type        = number
  default     = 32
}

variable "backup_retention_days" {
  description = "Nombre de jours de rétention des sauvegardes"
  type        = number
  default     = 7
}

variable "geo_redundant_backup" {
  description = "Activer la sauvegarde géo-redondante"
  type        = bool
  default     = false
}

variable "high_availability" {
  description = "Activer la haute disponibilité"
  type        = bool
  default     = false
}
