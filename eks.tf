module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  
  # Configuración de red
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets  # El argumento correcto es subnet_ids, no subnets

  # Configuración de encriptación (reemplaza enable_secrets_encryption)
  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  # Configuración de nodos (reemplaza node_groups)
  eks_managed_node_groups = {
    wordpress = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "production"
    Name        = var.cluster_name
  }
}

# Recurso KMS necesario para la encriptación
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Política de acceso para los nodos
data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}