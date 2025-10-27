
Cluster creation
```yaml
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
# CLUSTER 1 (us-east-1)
# -------------------------------------------------------

data "aws_vpc" "cluster1" {
  provider = aws.us-east-1
  default  = true
}

data "aws_subnets" "cluster1" {
  provider = aws.us-east-1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster1.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"]
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "cluster1_eks_cluster_role" {
  name     = "cluster1-eks-cluster-role"
  provider = aws.us-east-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster1_eks_cluster_policy" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster1_eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "cluster1" {
  name     = "cluster1"
  provider = aws.us-east-1
  role_arn = aws_iam_role.cluster1_eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.cluster1.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster1_eks_cluster_policy
  ]
}

# IAM Role for Node Group
resource "aws_iam_role" "cluster1_eks_node_group_role" {
  name     = "cluster1-eks-node-group-role"
  provider = aws.us-east-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster1_eks_worker_node_policy" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cluster1_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cluster1_eks_cni_policy" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cluster1_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cluster1_ec2_container_registry_readonly" {
  provider   = aws.us-east-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cluster1_eks_node_group_role.name
}

# Node Group
resource "aws_eks_node_group" "cluster1" {
  provider        = aws.us-east-1
  cluster_name    = aws_eks_cluster.cluster1.name
  node_group_name = "cluster1-node-group"
  node_role_arn   = aws_iam_role.cluster1_eks_node_group_role.arn
  subnet_ids      = data.aws_subnets.cluster1.ids

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster1_eks_worker_node_policy,
    aws_iam_role_policy_attachment.cluster1_eks_cni_policy,
    aws_iam_role_policy_attachment.cluster1_ec2_container_registry_readonly
  ]
}

# -------------------------------------------------------
# CLUSTER 2 (ap-south-1)
# -------------------------------------------------------

data "aws_vpc" "cluster2" {
  provider = aws.ap-south-1
  default  = true
}

data "aws_subnets" "cluster2" {
  provider = aws.ap-south-1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster2.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-south-1a", "ap-south-1b"]
  }
}

resource "aws_iam_role" "cluster2_eks_cluster_role" {
  name     = "cluster2-eks-cluster-role"
  provider = aws.ap-south-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster2_eks_cluster_policy" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster2_eks_cluster_role.name
}

resource "aws_eks_cluster" "cluster2" {
  name     = "cluster2"
  provider = aws.ap-south-1
  role_arn = aws_iam_role.cluster2_eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.cluster2.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster2_eks_cluster_policy
  ]
}

resource "aws_iam_role" "cluster2_eks_node_group_role" {
  name     = "cluster2-eks-node-group-role"
  provider = aws.ap-south-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster2_eks_worker_node_policy" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cluster2_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cluster2_eks_cni_policy" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cluster2_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cluster2_ec2_container_registry_readonly" {
  provider   = aws.ap-south-1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cluster2_eks_node_group_role.name
}

resource "aws_eks_node_group" "cluster2" {
  provider        = aws.ap-south-1
  cluster_name    = aws_eks_cluster.cluster2.name
  node_group_name = "cluster2-node-group"
  node_role_arn   = aws_iam_role.cluster2_eks_node_group_role.arn
  subnet_ids      = data.aws_subnets.cluster2.ids

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster2_eks_worker_node_policy,
    aws_iam_role_policy_attachment.cluster2_eks_cni_policy,
    aws_iam_role_policy_attachment.cluster2_ec2_container_registry_readonly
  ]
}

# -------------------------------------------------------
# Outputs
# -------------------------------------------------------
output "cluster1_endpoint" {
  value = aws_eks_cluster.cluster1.endpoint
}

output "cluster1_name" {
  value = aws_eks_cluster.cluster1.name
}

output "cluster2_endpoint" {
  value = aws_eks_cluster.cluster2.endpoint
}

output "cluster2_name" {
  value = aws_eks_cluster.cluster2.name
}
```

Create the infra using terraform
```
terraform init
terraform apply --auto-approve
```

Get the kubeconfig file
```
aws eks update-kubeconfig --region us-east-1 --name cluster1
kubectl get nodes -A
aws eks update-kubeconfig --region ap-south-1 --name cluster2
kubectl get nodes -A
```


Install ArgoCD
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
```

Install ArgoRollouts
```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
sudo chmod +x /usr/local/bin/kubectl-argo-rollouts
```

ArgoCLI Installation:


ArgoCLI login
```
argocd login localhost:8080 --username admin --password <password>

Get password from `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo`

```
argocd cluster list
argocd cluster add cluster1
argocd cluster add cluster2
```

Application creation:

Create Project:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: guestbook
  namespace: argocd
spec:
  description: Project for test repo with all clusters and namespaces allowed
  sourceRepos:
    - https://github.com/udemykcloud/Argocd.git
  destinations:
    # ✅ Cluster1 (us-east-1)
    - namespace: '*'
      server: https://CA28808FF985FFC343B5FD8D46805906.gr7.us-east-1.eks.amazonaws.com
    # ✅ Cluster2 (ap-south-1)
    - namespace: '*'
      server: https://D2E6AF0030498F0D3E430969326C2440.yl4.ap-south-1.eks.amazonaws.com
  # Allow creating Namespaces and all namespaced resources
  clusterResourceWhitelist:
    - group: ""
      kind: Namespace
  namespaceResourceWhitelist:
    - group: "*"
      kind: "*"
```

Guestbook Argo Application deploy into cluster1:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main
    path: section6/guestbook/base
  destination:
    server: https://CA28808FF985FFC343B5FD8D46805906.gr7.us-east-1.eks.amazonaws.com
    namespace: stg
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Moderator Argo Application deploy into cluster2:
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: moderator
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main  
    path: section6/moderator/base
  destination:
    server: https://D2E6AF0030498F0D3E430969326C2440.yl4.ap-south-1.eks.amazonaws.com
    namespace: stg
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```


