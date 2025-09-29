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
└── guestbook/
    ├── applications
    │     ├── prod-app.yaml
    │     ├── project.yaml
    │     └── staging-app.yaml
    ├── base
    │   ├── guestbook-ingress.yaml
    │   ├── guestbook-rollout.yaml
    │   ├── guestbook-ui-svc.yaml
    │   └── kustomization.yaml
    └── overlays
        ├── prod
        │   └── kustomization.yaml
        └── staging
            └── kustomization.yaml
└── moderator/
    ├── applications
    │   ├── staging-app.yaml
    │   └── prod-app.yaml
    ├── base
    │   ├── kustomization.yaml
    │   ├── moderator-rollout.yaml
    │   └── moderator-svc.yaml
    └── overlays
        ├── prod
        │   └── kustomization.yaml
        └── staging
            └── kustomization.yaml
```

## Create guestbook application for 2 environments
staging-app.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-stg
  namespace: argocd
  annotations:
    argocd-image-updater.argoproj.io/git-branch: staging
    argocd-image-updater.argoproj.io/image-list: myimage=udemykcloud534/guestbook  
    argocd-image-updater.argoproj.io/myimage.allow-tags: regexp:.*
    argocd-image-updater.argoproj.io/myimage.ignore-tags: latest, dev
    argocd-image-updater.argoproj.io/myimage.update-strategy: newest-build
    argocd-image-updater.argoproj.io/myimage.kustomize.image-name: udemykcloud534/guestbook 
    argocd-image-updater.argoproj.io/myimage.force-update: "true"
    argocd-image-updater.argoproj.io/write-back-method: git:secret:argocd/git-creds
    argocd-image-updater.argoproj.io/write-back-target: "kustomization:../../base"
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: staging      # Branch for staging
    path: argo-iu-argo-events/overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: stg
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

prod-app.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-prod
  namespace: argocd
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main      # Branch for prod
    path: argo-iu-argo-events/overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Create moderator application for 3 environments
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: moderator-stg
  namespace: argocd
  annotations:
    argocd-image-updater.argoproj.io/git-branch: staging
    argocd-image-updater.argoproj.io/image-list: myimage=udemykcloud534/moderator  
    argocd-image-updater.argoproj.io/myimage.allow-tags: regexp:.*
    argocd-image-updater.argoproj.io/myimage.ignore-tags: latest, dev
    argocd-image-updater.argoproj.io/myimage.update-strategy: newest-build
    argocd-image-updater.argoproj.io/myimage.kustomize.image-name: udemykcloud534/moderator 
    argocd-image-updater.argoproj.io/myimage.force-update: "true"
    argocd-image-updater.argoproj.io/write-back-method: git:secret:argocd/git-creds
    argocd-image-updater.argoproj.io/write-back-target: "kustomization:../../base"
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: staging      # Branch for staging
    path: moderator/overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: stg
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

prod-app.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: moderator-prod
  namespace: argocd
  annotations:
    argocd-image-updater.argoproj.io/git-branch: staging
    argocd-image-updater.argoproj.io/image-list: myimage=udemykcloud534/moderator  
    argocd-image-updater.argoproj.io/myimage.allow-tags: regexp:.*
    argocd-image-updater.argoproj.io/myimage.ignore-tags: latest, dev
    argocd-image-updater.argoproj.io/myimage.update-strategy: newest-build
    argocd-image-updater.argoproj.io/myimage.kustomize.image-name: udemykcloud534/moderator 
    argocd-image-updater.argoproj.io/myimage.force-update: "true"
    argocd-image-updater.argoproj.io/write-back-method: git:secret:argocd/git-creds
    argocd-image-updater.argoproj.io/write-back-target: "kustomization:../../base"
spec:
  project: guestbook
  source:
    repoURL: 'https://github.com/udemykcloud/Argocd.git'
    targetRevision: main      # Branch for staging
    path: moderator/overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Using applications for each environment would duplicate the same code again and again. To overcome this, we can use ApplicationSet.

## Create applications for 2 environments using ApplicationSet 
appset.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: guestbook-appset
  namespace: argocd
spec:
  generators:
    - list:
        elements:
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
        name: "{{cluster}}"        # staging-cluster / prod-cluster
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

