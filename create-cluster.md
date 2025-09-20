# Create EKS cluster


## Prequisite Install terraform 

1. Download terraform based on the OS

```
https://developer.hashicorp.com/terraform/install
```
2. unzip the downloaded terraform package

```
unzip terraform_1.13.3_darwin_arm64
```
3. move the Terraform binary to /usr/local/bin/:

```
sudo mv terraform /usr/local/bin/
```
4. verify terraform is installed
```
terraform -version
```

## EKS Cluster Creation

```


terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Default subnets in VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Subnet details (to get AZ info)
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# Available AZs (take first 2 dynamically)
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Pick the first 2 available AZs in the region
  chosen_azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Pick only subnets in those 2 AZs
  selected_subnets = tolist([
    for s in data.aws_subnet.details : s.id
    if contains(local.chosen_azs, s.availability_zone)
  ])
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "demo-cluster"
  cluster_version = "1.30"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = local.selected_subnets

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      min_size       = 2
      max_size       = 2
      instance_types = ["t3.medium"]
    }
  }
}

# Get current region for kubeconfig output
data "aws_region" "current" {}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

```
