# -------------------------------------------------------
# Providers
# -------------------------------------------------------
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "ap-south-1"
}

# -------------------------------------------------------
# DEV CLUSTER (us-east-1)
# -------------------------------------------------------

# Data sources
data "aws_vpc" "dev" {
  provider = aws.us-east-1
  default  = true
}

data "aws_subnets" "dev" {
  provider = aws.us-east-1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"]
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "dev_eks_cluster_role" {
  name     = "dev-eks-cluster-role"
  provider = aws.us-east-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dev_eks_cluster_policy" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.dev_eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "dev" {
  name     = "dev-argocd-cluster"
  provider = aws.us-east-1
  role_arn = aws_iam_role.dev_eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.dev.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.dev_eks_cluster_policy
  ]
}

# IAM Role for Node Group
resource "aws_iam_role" "dev_eks_node_group_role" {
  name     = "dev-eks-node-group-role"
  provider = aws.us-east-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dev_eks_worker_node_policy" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.dev_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "dev_eks_cni_policy" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.dev_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "dev_ec2_container_registry_readonly" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.dev_eks_node_group_role.name
}

# Node Group
resource "aws_eks_node_group" "dev" {
  provider        = aws.us-east-1
  cluster_name    = aws_eks_cluster.dev.name
  node_group_name = "dev-node-group"
  node_role_arn   = aws_iam_role.dev_eks_node_group_role.arn
  subnet_ids      = data.aws_subnets.dev.ids

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.dev_eks_worker_node_policy,
    aws_iam_role_policy_attachment.dev_eks_cni_policy,
    aws_iam_role_policy_attachment.dev_ec2_container_registry_readonly
  ]
}

# -------------------------------------------------------
# PROD CLUSTER (ap-south-1)
# -------------------------------------------------------

# Data sources
data "aws_vpc" "prod" {
  provider = aws.ap-south-1
  default  = true
}

data "aws_subnets" "prod" {
  provider = aws.ap-south-1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.prod.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-south-1a", "ap-south-1b"]
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "prod_eks_cluster_role" {
  name     = "prod-eks-cluster-role"
  provider = aws.ap-south-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prod_eks_cluster_policy" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.prod_eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "prod" {
  name     = "prod-argocd-cluster"
  provider = aws.ap-south-1
  role_arn = aws_iam_role.prod_eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.prod.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.prod_eks_cluster_policy
  ]
}

# IAM Role for Node Group
resource "aws_iam_role" "prod_eks_node_group_role" {
  name     = "prod-eks-node-group-role"
  provider = aws.ap-south-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prod_eks_worker_node_policy" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.prod_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "prod_eks_cni_policy" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.prod_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "prod_ec2_container_registry_readonly" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.prod_eks_node_group_role.name
}

# Node Group
resource "aws_eks_node_group" "prod" {
  provider        = aws.ap-south-1
  cluster_name    = aws_eks_cluster.prod.name
  node_group_name = "prod-node-group"
  node_role_arn   = aws_iam_role.prod_eks_node_group_role.arn
  subnet_ids      = data.aws_subnets.prod.ids

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.prod_eks_worker_node_policy,
    aws_iam_role_policy_attachment.prod_eks_cni_policy,
    aws_iam_role_policy_attachment.prod_ec2_container_registry_readonly
  ]
}

# -------------------------------------------------------
# Outputs
# -------------------------------------------------------
output "dev_cluster_endpoint" {
  value = aws_eks_cluster.dev.endpoint
}

output "dev_cluster_name" {
  value = aws_eks_cluster.dev.name
}

output "prod_cluster_endpoint" {
  value = aws_eks_cluster.prod.endpoint
}

output "prod_cluster_name" {
  value = aws_eks_cluster.prod.name
}
