# Adapting to Kustomize from Native Kubernetes Manifests

Most teams start with **plain Kubernetes manifests** — writing raw `Deployment`, `Service`, and `Ingress` YAML files. While this works for simple setups, it becomes repetitive and hard to maintain when you need **multiple environments** (dev, staging, prod) with small differences (replica count, image tags, resource limits, etc.).

This is where **Kustomize** helps.  
It lets you **reuse your base manifests** and create **overlays** for environment-specific differences, without duplicating YAML.

---

## Step 1: Start with Native Manifests (Base)

Suppose you already have the following files:

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        ports:
        - containerPort: 80
```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
```

---

## Step 2: Create a `base` Directory

Move your original manifests into a `base/` folder.

```
kustomize-demo/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
```

Inside `base/kustomization.yaml`:

```yaml
resources:
  - deployment.yaml
  - service.yaml
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
# overlays/dev/kustomization.yaml
bases:
  - ../../base

namePrefix: dev-

patchesStrategicMerge:
  - patch-replicas.yaml
```

```yaml
# overlays/dev/patch-replicas.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
```

---

### Example: Staging Overlay

```yaml
# overlays/staging/kustomization.yaml
bases:
  - ../../base

namePrefix: staging-

patchesStrategicMerge:
  - patch-replicas.yaml
  - patch-image.yaml
```

```yaml
# overlays/staging/patch-replicas.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
```

```yaml
# overlays/staging/patch-image.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:staging
```

---

### Example: Prod Overlay

```yaml
# overlays/prod/kustomization.yaml
bases:
  - ../../base

namePrefix: prod-

patchesStrategicMerge:
  - patch-replicas.yaml
  - patch-image.yaml
```

```yaml
# overlays/prod/patch-replicas.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 5
```

```yaml
# overlays/prod/patch-image.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:stable
```

---

## Step 5: Deploy Using Kustomize

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
