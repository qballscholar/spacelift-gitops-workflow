data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# No backend configuration - Spacelift manages state
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = "spacelift-eks-cluster"
  cluster_version = "1.30"

  # Disable log group creation
  cluster_enabled_log_types = []
  create_cloudwatch_log_group = false

  # Use AWS-managed key for EKS
  cluster_encryption_config = {
  resources        = ["secrets"]
  provider_key_arn = "alias/aws/eks"  # Use AWS-managed key
  }
  create_kms_key = false

  # Use variables passed from root module
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  # IAM role configuration
  create_iam_role = true
  iam_role_name   = "spacelift-eks-cluster-role"
  iam_role_use_name_prefix = false

  # Use managed policy only to avoid custom policy creation errors
  iam_role_additional_policies = {
    additional = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
  }

   # Add IRSA configuration to prevent OIDC errors
   enable_irsa = true
  
  eks_managed_node_groups = {
    main = {
      min_size     = 2
      max_size     = 4
      desired_size = 2
      
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
  
  # Use API authentication mode
  authentication_mode = "API"

  # Enable cluster creator admin permissions
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
    GitOps      = "true"
  }
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "EKS Cluster API Endpoint"
}

output "cluster_name" {
  value = module.eks.cluster_name
  description = "EKS Cluster Name"
  }

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster"
}
