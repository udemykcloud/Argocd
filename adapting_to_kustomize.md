# Adapting to Kustomize from Native Kubernetes Manifests

Most teams start with **plain Kubernetes manifests** — writing raw `Deployment`, `Service`, and `Ingress` YAML files. While this works for simple setups, it becomes repetitive and hard to maintain when you need **multiple environments** (dev, staging, prod) with small differences (replica count, image tags, resource limits, etc.).

This is where **Kustomize** helps.  
It lets you **reuse your base manifests** and create **overlays** for environment-specific differences, without duplicating YAML.

---

## Step 1: Start with Native Manifests (Base)

Suppose you already have the following files:

```yaml
# base/guestbook-rollout.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook-ui
spec:
  replicas: 3
  revisionHistoryLimit: 2
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
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          imagePullSecrets:
            - name: dockerhub-secret
  strategy:
    blueGreen:
      activeService: guestbook-ui
      previewService: guestbook-ui-canary
      autoPromotionEnabled: true
      scaleDownDelaySeconds: 300
```

```yaml
# base/guestbook-ui-svc.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: guestbook-ui
  namespace: default
spec:
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: guestbook-ui
---
apiVersion: v1
kind: Service
metadata:
  name: guestbook-ui-canary
  namespace: default
spec:
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: guestbook-ui
```

```yaml
# base/guestbook-ingress.yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: guestbook-ui-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: guestbook-ui
                port:
                  number: 80
```

---

## Step 2: Create a `base` Directory

Move your original manifests into a `base/` folder.

```
kustomize-demo/
├── base/
│   ├── guestbook-ui-svc.yaml
│   ├── guestbook-rollout.yaml
│   └── guestbook-ingress.yaml
```

Inside `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- guestbook-ui-svc.yaml
- guestbook-rollout.yaml
- guestbook-ingress.yaml
```

This defines the **base configuration** shared across all environments.

---

## Step 3: Create `overlays` for Environments

Now, create a folder structure for environments:

```
kustomize-demo/
├── base/
├── overlays/
│   ├── dev/
│   │   └── kustomization.yaml
│   ├── staging/
│   │   └── kustomization.yaml
│   └── prod/
│       └── kustomization.yaml
```

Each overlay will **reference the base** and apply changes.

---

## Step 4: Apply Patches in Overlays

### Example: Dev Overlay

```yaml
# overlays/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namePrefix: dev-
namespace: dev

resources:
- ../../base

images:
- name: udemykcloud534/guestbook
  newName: udemykcloud534/guestbook
  newTag: blue

patches:
  # Inline replica patch
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 1

  # Inline rollout service names patch
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/strategy/blueGreen
        value:
          activeService: dev-guestbook-ui
          previewService: dev-guestbook-ui-canary
          autoPromotionEnabled: false
          autoPromotionSeconds: 30
          scaleDownDelaySeconds: 10

  # Inline ingress patch
  - target:
      kind: Ingress
      name: guestbook-ui-ingress
    patch: |-
      - op: add
        path: /metadata/annotations
        value:
          kubernetes.io/ingress.class: nginx
          nginx.ingress.kubernetes.io/rewrite-target: /$2
      - op: replace
        path: /spec/rules
        value:
          - host: guestbook.local
            http:
              paths:
                - path: /dev(/|$)(.*)
                  pathType: Prefix
                  backend:
                    service:
                      name: dev-guestbook-ui
                      port:
                        number: 80
                - path: /dev-preview(/|$)(.*)
                  pathType: Prefix
                  backend:
                    service:
                      name: dev-guestbook-ui-canary
                      port:
                        number: 80
```


---

### Example: Staging Overlay

```yaml
# overlays/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namePrefix: stg-
namespace: stg

resources:
- ../../base

images:
- name: udemykcloud534/guestbook
  newName: udemykcloud534/guestbook
  newTag: yellow

patches:
  # Inline replica patch
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2

  # Inline rollout service names patch
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/strategy/blueGreen
        value:
          activeService: stg-guestbook-ui
          previewService: stg-guestbook-ui-canary
          autoPromotionEnabled: false
          autoPromotionSeconds: 30
          scaleDownDelaySeconds: 10

  # Inline ingress patch
  - target:
      kind: Ingress
      name: guestbook-ui-ingress
    patch: |-
      - op: add
        path: /metadata/annotations
        value:
          kubernetes.io/ingress.class: nginx
          nginx.ingress.kubernetes.io/rewrite-target: /$2
      - op: replace
        path: /spec/rules
        value:
          - host: guestbook.local
            http:
              paths:
                - path: /stg(/|$)(.*)
                  pathType: Prefix
                  backend:
                    service:
                      name: stg-guestbook-ui
                      port:
                        number: 80
                - path: /stg-preview(/|$)(.*)
                  pathType: Prefix
                  backend:
                    service:
                      name: stg-guestbook-ui-canary
                      port:
                        number: 80
```


---

### Example: Prod Overlay

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namePrefix: prod-
namespace: prod

resources:
- ../../base

images:
- name: udemykcloud534/guestbook
  newName: udemykcloud534/guestbook
  newTag: green

patches:
  # Inline replica patch
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2

  # Inline rollout service names patch
  - target:
      kind: Rollout
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/strategy/blueGreen
        value:
          activeService: prod-guestbook-ui
          previewService: prod-guestbook-ui-canary
          autoPromotionEnabled: false
          autoPromotionSeconds: 30
          scaleDownDelaySeconds: 10

  # Inline ingress patch
  - target:
      kind: Ingress
      name: guestbook-ui-ingress
    patch: |-
      - op: add
        path: /metadata/annotations
        value:
          kubernetes.io/ingress.class: nginx
          nginx.ingress.kubernetes.io/rewrite-target: /$2
      - op: replace
        path: /spec/rules
        value:
          - host: guestbook.local
            http:
              paths:
                - path: /prod(/|$)(.*)
                  pathType: Prefix
                  backend:
                    service:
                      name: prod-guestbook-ui
                      port:
                        number: 80
                - path: /prod-preview(/|$)(.*)
                  pathType: Prefix
                  backend:
                    service:
                      name: prod-guestbook-ui-canary
                      port:
                        number: 80
```


---

## Step 5: Build Using Kustomize

To build and verify the final Kubernetes manifest file which is going to be applied:

```bash
# Dev
kustomize build overlays/dev

# Staging
kustomize build overlays/staging

# Prod
kustomize build overlays/prod
```

## Step 6: Deploy Using Kustomize

To apply each environment:

```bash
# Dev
kubectl apply -k overlays/dev

# Staging
kubectl apply -k overlays/staging

# Prod
kubectl apply -k overlays/prod
```

---

## Benefits of Adopting Kustomize

- **No duplication** of manifests — write once, reuse everywhere.  
- **Declarative overlays** make environment differences explicit.  
- **Built-in to kubectl** — no extra installation needed.  
- **Easy integration with GitOps tools** like ArgoCD and Argo Rollouts.  

---

## Summary

- Start by moving your plain manifests into a **base**.  
- Create **overlays** for each environment.  
- Apply **patches** (replicas, image tags, configs) per environment.  
- Deploy with `kubectl apply -k`.  

This makes your deployments **cleaner, reusable, and GitOps-friendly**.
