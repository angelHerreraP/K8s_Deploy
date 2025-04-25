resource "random_password" "db_password" {
  length  = 20
  special = true
}

resource "random_string" "db_username" {
  length  = 12
  special = false
  upper   = true
}

resource "aws_db_instance" "wordpress" {
  identifier           = "wordpress-db"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "wordpress"
  username             = random_string.db_username.result
  password             = random_password.db_password.result
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = false
  backup_retention_period = 7
  deletion_protection     = true

  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  storage_encrypted      = var.enable_rds_encryption

  tags = {
    Name        = "wordpress-db"
    Environment = "production"
  }
}

resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "rds" {
  name        = "wordpress-rds-sg"
  description = "Permitir acceso desde EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-rds-sg"
  }
}