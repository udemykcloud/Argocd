## Cluster Registration in ArgoCD

You must register each environment’s cluster with ArgoCD:
```
# Example: add dev cluster
argocd cluster add dev-cluster-context --name dev-cluster

# staging
argocd cluster add staging-cluster-context --name staging-cluster

# prod
argocd cluster add prod-cluster-context --name prod-cluster
```

## Repo structure
```
gitops-repo/
└── service-a/
    ├── base/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── kustomization.yaml
    │
    ├── overlays/
    │   ├── dev/
    │   │   ├── kustomization.yaml
    │   │   └── replica-patch.yaml
    │   │
    │   ├── staging/
    │   │   ├── kustomization.yaml
    │   │   └── replica-patch.yaml
    │   │
    │   └── prod/
    │       ├── kustomization.yaml
    │       └── replica-patch.yaml
    │
    └── application/
        └── appset.yaml   # ApplicationSet for serviceA
└── service-b/
    ├── base/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── kustomization.yaml
    │
    ├── overlays/
    │   ├── dev/
    │   │   ├── kustomization.yaml
    │   │   └── replica-patch.yaml
    │   │
    │   ├── staging/
    │   │   ├── kustomization.yaml
    │   │   └── replica-patch.yaml
    │   │
    │   └── prod/
    │       ├── kustomization.yaml
    │       └── replica-patch.yaml
    │
    └── application/
        └── appset.yaml   # ApplicationSet for serviceB
```

## Create applications for 3 environments using ApplicationSet 
appset.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: serviceA-appset
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            cluster: dev-cluster
            namespace: dev
            path: serviceA/overlays/dev
          - env: staging
            cluster: staging-cluster
            namespace: staging
            path: serviceA/overlays/staging
          - env: prod
            cluster: prod-cluster
            namespace: prod
            path: serviceA/overlays/prod
  template:
    metadata:
      name: recommendationservice-{{env}}
    spec:
      project: default
      source:
        repoURL: https://github.com/org/gitops-repo.git
        targetRevision: main
        path: "{{path}}"
      destination:
        name: "{{cluster}}"        # dev-cluster / staging-cluster / prod-cluster
        namespace: "{{namespace}}"
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```


