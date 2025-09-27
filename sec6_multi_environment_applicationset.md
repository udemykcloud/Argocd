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
Here I have used same cluster for multiple environments

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
  name: guestbook-appset
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            cluster: in-cluster # dev-cluster / staging-cluster / prod-cluster
            namespace: dev
            path: argo-iu-argo-events/overlays/dev
          - env: staging
            cluster: in-cluster
            namespace: staging
            path: argo-iu-argo-events/overlays/staging
          - env: prod
            cluster: in-cluster
            namespace: prod
            path: argo-iu-argo-events/overlays/prod
  template:
    metadata:
      name: guestbook-{{env}}
    spec:
      project: guestbook
      source:
        repoURL: 'https://github.com/udemykcloud/Argocd.git'
        targetRevision: main
        path: "{{path}}"
      destination:
        name: "{{cluster}}"        # dev-cluster / staging-cluster / prod-cluster
        namespace: "{{namespace}}"
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

```
$ kubectl get applicationset -n argocd
NAME               AGE
guestbook-appset   7m43s
```

