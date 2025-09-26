
## Argocd Deployment using helm

# Prerequisite

1.  Install argo cd follow argocd-installation.md
2.  Install Argo Roll out follow argorollout-installation.md


## Install Ingress controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```

## create argo rollout yaml file

1. Clone the repo
```
https://github.com/udemykcloud/helm.git
```
2. create namespace
```
kubectl create namespace dev
```
3. deploy the guestbook app using helm
```
kubectl apply -f helm/blob/main/gitops-repo/environments/dev/application.yaml
```
4. Access the guestbook-UI using the loadbalancer UI from the browser
```
kubectl get ingress -A 
```

## Deploying the guestbook-UI app on production cluster using  helm charts and argocd 

1. spin eks cluster called prod-argocd

   ```
# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Data source to fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to fetch subnets in specific availability zones (us-east-1a and us-east-1b)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"]
  }
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

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

# Attach the AmazonEKSClusterPolicy to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create the EKS cluster
resource "aws_eks_cluster" "example" {
  name     = "argocd-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  # Ensure that IAM role permissions are created before and deleted after EKS cluster handling
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Create IAM role for EKS node group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

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

# Attach policies to the node group role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# Create EKS node group
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "example-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = data.aws_subnets.default.ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_readonly
  ]
}

# Output the EKS cluster endpoint
output "cluster_endpoint" {
  value = aws_eks_cluster.example.endpoint
}

# Output the cluster name
output "cluster_name" {
  value = aws_eks_cluster.example.name
}
```


   
