
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

Note down the outputs we get like this
```
Outputs:

dev_cluster_endpoint = "https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com"
dev_cluster_name = "dev-argocd-cluster"
prod_cluster_endpoint = "https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com"
prod_cluster_name = "prod-argocd-cluster"
```

Creation of 2 clusters done

## Get the kubeconfig file
```
aws eks update-kubeconfig --region us-east-1 --name dev-argocd-cluster
kubectl get nodes -A
aws eks update-kubeconfig --region ap-south-1 --name prod-argocd-cluster
kubectl get nodes -A
```


## Install ArgoCD in dev-cluster
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
```

## Install ArgoRollouts in both the clusters(dev and prod)
```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
sudo chmod +x /usr/local/bin/kubectl-argo-rollouts
```
Note: since we are using rollout objects, it's custom controller has to be available in both the clusters

## ArgoCLI Installation:

## ArgoCLI login
```
$ argocd login localhost:8080 --username admin  --password lm-BSZPIaa254tAf
WARNING: server certificate had error: tls: failed to verify certificate: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
'admin:login' logged in successfully
Context 'localhost:8080' updated

Get password from `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo`
```

```
$ argocd cluster list
$ argocd cluster add arn:aws:eks:us-east-1:020930354342:cluster/dev-argocd-cluster
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `arn:aws:eks:us-east-1:020930354342:cluster/dev-argocd-cluster` with full cluster level privileges. Do you want to continue [y/N]? y
{"level":"info","msg":"ServiceAccount \"argocd-manager\" created in namespace \"kube-system\"","time":"2025-11-04T18:29:39+05:30"}
{"level":"info","msg":"ClusterRole \"argocd-manager-role\" created","time":"2025-11-04T18:29:39+05:30"}
{"level":"info","msg":"ClusterRoleBinding \"argocd-manager-role-binding\" created","time":"2025-11-04T18:29:40+05:30"}
{"level":"info","msg":"Created bearer token secret \"argocd-manager-long-lived-token\" for ServiceAccount \"argocd-manager\"","time":"2025-11-04T18:29:40+05:30"}
Cluster 'https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com' added

$ argocd cluster add arn:aws:eks:ap-south-1:020930354342:cluster/prod-argocd-cluster
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `arn:aws:eks:ap-south-1:020930354342:cluster/prod-argocd-cluster` with full cluster level privileges. Do you want to continue [y/N]? y
{"level":"info","msg":"ServiceAccount \"argocd-manager\" created in namespace \"kube-system\"","time":"2025-11-04T18:29:49+05:30"}
{"level":"info","msg":"ClusterRole \"argocd-manager-role\" created","time":"2025-11-04T18:29:49+05:30"}
{"level":"info","msg":"ClusterRoleBinding \"argocd-manager-role-binding\" created","time":"2025-11-04T18:29:49+05:30"}
{"level":"info","msg":"Created bearer token secret \"argocd-manager-long-lived-token\" for ServiceAccount \"argocd-manager\"","time":"2025-11-04T18:29:49+05:30"}
Cluster 'https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com' added


$ argocd cluster list
SERVER                                                                     NAME                                                             VERSION  STATUS   MESSAGE                                                  PROJECT
https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com  arn:aws:eks:ap-south-1:020930354342:cluster/prod-argocd-cluster           Unknown  Cluster has no applications and is not being monitored.  
https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com   arn:aws:eks:us-east-1:020930354342:cluster/dev-argocd-cluster             Unknown  Cluster has no applications and is not being monitored.  
https://kubernetes.default.svc                                             in-cluster                                                                Unknown  Cluster has no applications and is not being monitored.  
```

# Deploy 2 microservices in each cluster

## Create Argo Applications

### Create Project: 

>> Update the destination clusters as dev and prod accordingly

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
    # ✅ Dev-Cluster (us-east-1)
    - namespace: '*'
      server: https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com
    - namespace: '*'
      server: https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com
  # Allow creating Namespaces and all namespaced resources
  clusterResourceWhitelist:
    - group: ""
      kind: Namespace
  namespaceResourceWhitelist:
    - group: "*"
      kind: "*"
```

### Guestbook Argo Application deploy into dev cluster and prod cluster:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-dev
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main
    path: section6/guestbook/base
  destination:
    server: https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-prod
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main
    path: section6/guestbook/base
  destination:
    server: https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Moderator Argo Application deploy into dev cluster and prod cluster:
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: moderator-dev
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main  
    path: section6/moderator/base
  destination:
    server: https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: moderator-prod
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main  
    path: section6/moderator/base
  destination:
    server: https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```


## Using ApplicationSets
Replace multiple Application YAMLs like: guestbook-dev, guestbook-prod, moderator-dev,moderator-prod

with a single ApplicationSet that dynamically creates all these apps.

```
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: guestbook-and-moderator
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          # ---- Dev Cluster ----
          - appName: guestbook
            environment: dev
            clusterServer: https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com
            path: section6/guestbook/base

          - appName: moderator
            environment: dev
            clusterServer: https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com
            path: section6/moderator/base

          # ---- Prod Cluster ----
          - appName: guestbook
            environment: prod
            clusterServer: https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com
            path: section6/guestbook/base

          - appName: moderator
            environment: prod
            clusterServer: https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com
            path: section6/moderator/base

  template:
    metadata:
      name: '{{appName}}-{{environment}}'
      namespace: argocd
    spec:
      project: guestbook
      source:
        repoURL: 'https://github.com/udemykcloud/Argocd.git'
        targetRevision: main
        path: '{{path}}'
      destination:
        server: '{{clusterServer}}'
        namespace: '{{environment}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

## Helm and Kustomize for managing multiple environments

Why: Reducing duplication in code. Same manifest files with only values passing based on the environment

In terms of Helm: 

1. Modify the manifest file as Helm charts and keep it in the manifest repo
2. Create values.yaml based on dev and prod 
3. Pass it in the application manifest 

In terms of Kustomize:

1. Use the same k8s native manifest files
2. create a kustomization.yaml file where apply only patches wherever changes required based on the environment. 

For eg: replica differs for dev and prod, its 2 and 4 respectively. We apply patch only for replica in kustomization.yaml file


### Helm:

Path contains files for this practical:
Argocd/section6/guestbook/helm

Argocd/section6/guestbook$ tree
.
└── helm
    ├── Chart.yaml
    ├── argo-applications
    │   ├── dev.yaml
    │   └── prod.yaml
    ├── templates
    │   ├── _helpers.tpl
    │   ├── rollout.yaml
    │   └── service.yaml
    ├── values-dev.yaml
    ├── values-prod.yaml
    └── values.yaml

Create Argo applications with helm values

argo-applications/dev.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-dev
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main
    path: section6/guestbook/helm
    helm:
      valueFiles:
        - values-dev.yaml
  destination:
    server: https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

argo-applications/prod.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-prod
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main
    path: section6/guestbook/helm
    helm:
      valueFiles:
        - values-prod.yaml
  destination:
    server: https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Modify the k8s manifest files as helm charts. Its available under templates
section6/guestbook/helm/templates/rollout.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: {{ include "guestbook-ui.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: {{ include "guestbook-ui.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "guestbook-ui.name" . }}
    spec:
      containers:
        - name: {{ include "guestbook-ui.name" . }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
  strategy:
    canary:
      stableService: {{ include "guestbook-ui.fullname" . }}
      canaryService: {{ include "guestbook-ui.fullname" . }}-canary
      steps:
        - setWeight: 50
        - pause: { duration: 30s }
        - setWeight: 100
```

section6/guestbook/helm/templates/service.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: {{ include "guestbook-ui.fullname" . }}
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: {{ include "guestbook-ui.name" . }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "guestbook-ui.fullname" . }}-canary
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: {{ include "guestbook-ui.name" . }}
```

section6/guestbook/helm/
values-dev.yaml
```
replicaCount: 1

image:
  repository: udemykcloud534/guestbook
  tag: green
```

values-prod.yaml
```
replicaCount: 2

image:
  repository: udemykcloud534/guestbook
  tag: green
```
section6/guestbook/helm/Chart.yaml
```
apiVersion: v2
name: guestbook-ui
description: Helm chart for guestbook-ui rollout using Argo Rollouts
type: application
version: 0.1.0
appVersion: "1.0.0"
```


##  Kustomize:

Path contains files for this practical:
Argocd/section6/guestbook/kustomize

base - contain original k8s manifest files
overlays - environment specific variables

Create Argoapplications

```
kubectl apply -f Argocd/section6/guestbook/kustomize/argo-applications/dev.yaml
kubectl apply -f Argocd/section6/guestbook/kustomize/argo-applications/prod.yaml
```

It points to 
Argocd/section6/guestbook/kustomize/overlays/dev for dev
Argocd/section6/guestbook/kustomize/overlays/prod for prod

Apply patches like replica counts directly in kustomization.yaml file under these directories

Argocd/section6/guestbook/kustomize$ tree
.
├── argo-applications
│   ├── dev.yaml
│   └── prod.yaml
├── base
│   ├── kustomization.yaml
│   ├── rollout.yaml
│   └── service.yaml
└── overlays
    ├── dev
    │   └── kustomization.yaml
    └── prod
        └── kustomization.yaml

Argocd/section6/guestbook/kustomize/argo-applications/dev.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-dev
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main
    path: section6/guestbook/kustomize/overlays/dev
  destination:
    server: https://1440EF309B7D8B599579E7FFC69D84F2.gr7.us-east-1.eks.amazonaws.com
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Argocd/section6/guestbook/kustomize/argo-applications/prod.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-prod
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main
    path: section6/guestbook/kustomize/overlays/prod
  destination:
    server: https://A62F1AB01F99B8668087E1A776089FE2.yl4.ap-south-1.eks.amazonaws.com
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Argocd/section6/guestbook/kustomize/base
rollout.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook-ui
spec:
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: guestbook-ui
  template:
    metadata:
      labels:
        app: guestbook-ui
    spec:
      containers:
        - name: guestbook-ui
          image: udemykcloud534/guestbook:green
          ports:
            - containerPort: 80

  strategy:
    canary:
      stableService: guestbook-ui
      canaryService: guestbook-ui-canary
      # Number of pods updated in the first step (percentage or count)
      steps:
        - setWeight: 50     # Send 50% of traffic to new version
        - pause: { duration: 30s } # Wait and observe
        - setWeight: 100    # Move all traffic to new version
```

service.yaml
```
apiVersion: v1	
kind: Service	
metadata:	
  name: guestbook-ui	
spec:	
  ports:	
  - port: 80	
    targetPort: 80	
  selector:	
    app: guestbook-ui
---
apiVersion: v1
kind: Service
metadata:
  name: guestbook-ui-canary
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: guestbook-ui
```

kustomization.yaml
```
resources:
  - rollout.yaml
  - service.yaml
```

section6/guestbook/kustomize/overlays/dev/kustomization.yaml
```
resources:
  - ../../base

patches:
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 1
```

section6/guestbook/kustomize/overlays/prod/kustomization.yaml
```
resources:
  - ../../base

patches:
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
```
