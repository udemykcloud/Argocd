
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
kubectl apply -f helm/gitops-repo/environments/dev/application.yaml
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
  name     = "prod-cluster"
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
2. Initiaize terraform

```
terraform init
```
3. Apply the changes

```
terraform apply -auto-approve
```
4. verify if EKS cluster is created
```
aws eks update-kubeconfig --region us-east-1 --name prod-cluster
kubectl get nodes -A

```
5. Install Argo-rollouts
follow argorollout-installation.md

6. Install ArgoCD 
follow argocd-installation.md

6. Install Ingress 
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```
7. log into argocd 

```
argocd login localhost:8080
Username: admin
Password: 
'admin:login' logged in successfully
Context 'localhost:8080' updated
```
8. Retrive the context name
```
kubectl config get-contexts
```
9. Add the prod-cluster to argo cd. prompt yes for service account creation. Name is reteive from the above command
```
argocd cluster add <Name>
```
10. Verify if prod-cluster is added to argocd 
```
argocd cluster list
```
11. Get the cluster endpoint
```
aws eks describe-cluster --name prod-cluster --query 'cluster.endpoint' --output text --region us-west-2
```

12. Edit the application.yaml server: https://**********************.gr7.us-west-2.eks.amazonaws.com eks cluster endpoint

13. install the crd for argocd 
```
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/application-crd.yaml
```
14. create namespace
```
kubectl create ns prod
```
15. Update the context back to argocd-cluster
```
aws eks update-kubeconfig --name argocd-cluster --region "us-east-1"
```

16. apply the helm charts for deploying in prod-cluster
```
kubectl apply -f helm/gitops-repo/environments/prod/application.yaml
```
17. Switch back to prod-cluster
```
aws eks update-kubeconfig --name prod-cluster --region "us-west-2"
```
18. get the loadbalancer dns
```
kubectl get ingress
```
19. Update the load balancer dns. I own a domain in go daddy called systemsdesigns.xyz. I created a CNAME record for prod.systemsdesigns.xyz.

<img width="1358" height="107" alt="Screenshot 2025-09-26 at 5 06 03 PM" src="https://github.com/user-attachments/assets/22e5b5fc-9144-4bc1-93fe-b28804ff4660" />


20. visit the guestbook app from the browser


<img width="1273" height="653" alt="Screenshot 2025-09-26 at 5 07 26 PM" src="https://github.com/user-attachments/assets/f8353c62-acee-4dcd-bb6a-12f76fd17e98" />






   
