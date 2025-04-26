resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%&()*+,-.:;<=>?[\\]^_{|}~" # Excluye '/', '@', '"', ' ' y otros inválidos
}


resource "random_string" "db_username" {
  length  = 12
  special = false
  upper   = true
}

resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "rds" {
  name        = "wordpress-rds-sg"
  description = "Allows traffic from EKS and private subnets"  # Usando solo ASCII
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "wordpress" {
  identifier             = "wordpress-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "wordpress"
  username               = "administrador"          # Usuario fijo
  password               = "admin123456789"         # Contraseña fija
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  backup_retention_period = 7
  deletion_protection     = false
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  storage_encrypted      = var.enable_rds_encryption
  publicly_accessible    = false

  tags = {
    Name        = "wordpress-db"
    Environment = "production"
  }
}
