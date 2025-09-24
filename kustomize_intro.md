# Introduction to Kustomize

Kustomize is a Kubernetes-native tool that helps you manage configuration in a clean, reusable, and declarative way. Unlike templating tools, Kustomize allows you to customize raw, template-free YAML files directly, enabling you to maintain a single source of truth while deploying to multiple environments (such as **dev**, **staging**, and **production**).

Kustomize is built into `kubectl`, so you can apply configurations without installing additional tools:

```bash
kubectl apply -k ./overlays/dev
```

This makes it simple for teams to adopt and use in their existing Kubernetes workflows.

---

## Key Features of Kustomize

- **Base and Overlays**: 
  - Define a **base** manifest (common configuration).
  - Layer environment-specific **overlays** (patches, name prefixes, labels, etc.) without duplicating YAML.

- **Patch Management**: 
  - Apply strategic merge patches or JSON patches to modify existing manifests.

- **No Templates**: 
  - Works on plain YAML with a declarative approach — no custom templating language.

- **Built-in with Kubectl**: 
  - Native to Kubernetes CLI since v1.14, ensuring zero additional dependency.

---

## How Kustomize Differs from Helm

Both **Helm** and **Kustomize** are popular tools for Kubernetes configuration management, but they solve problems differently:

| Feature / Aspect        | Kustomize                                                   | Helm                                                       |
|--------------------------|-------------------------------------------------------------|------------------------------------------------------------|
| **Approach**             | Purely declarative, YAML patches and overlays               | Template-based, uses Go templating language                |
| **Learning Curve**       | Easier (just YAML, no new language to learn)                | Steeper (requires understanding Helm templating syntax)     |
| **Tooling**              | Integrated into `kubectl` (`kubectl apply -k`)              | Separate CLI (`helm install/upgrade`)                      |
| **Reuse**                | Bases + overlays for environment reuse                      | Charts + values.yaml for reuse and parameterization         |
| **Flexibility**          | Strong for managing small-to-medium complexity configs      | Strong for packaging, distribution, and complex scenarios   |
| **Package Sharing**      | No built-in packaging/distribution mechanism                | Helm charts can be versioned, shared via chart repositories |
| **Dependencies**         | Does not handle application dependencies                   | Supports dependencies via subcharts                        |

---

## When to Use What?

- **Use Kustomize if**:
  - You want a simple, declarative way to manage Kubernetes YAML across multiple environments.
  - You prefer minimal tooling and native integration with `kubectl`.
  - Your use case doesn’t need templating or packaging/distribution.

- **Use Helm if**:
  - You need to package and share applications with others (charts).
  - You want templating for highly dynamic configurations.
  - You’re deploying complex applications with dependencies.

---

## Summary

- **Kustomize** → Great for environment overlays, pure YAML, and native integration.  
- **Helm** → Great for templating, packaging, and distribution of applications.  

In this course, we will use **Kustomize** to demonstrate how multiple environments (dev, staging, prod) can be deployed in a clean and maintainable way, alongside **ArgoCD** and **Argo Rollouts**.
