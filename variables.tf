variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
  default     = "wordpress-eks"
}

variable "db_password" {
  description = "Contraseña para la base de datos"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Usuario para la base de datos"
  type        = string
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitidos para acceder al LoadBalancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # ¡Cambia esto en producción!
}

variable "enable_rds_encryption" {
  description = "Habilita encryption at rest para RDS"
  type        = bool
  default     = true
}