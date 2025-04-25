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
  description = "CIDR blocks allowed to access the WordPress LoadBalancer"
  type        = list(string)
  default     = ["YOUR_IP/32"] # Replace with your IP or corporate CIDR
}

variable "enable_rds_encryption" {
  description = "Enable encryption at rest for RDS"
  type        = bool
  default     = true
}