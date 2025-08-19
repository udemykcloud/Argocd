argocd account list

argocd account get --account bob

# if you are managing users as the admin user, <current-user-password> should be the current admin password.
argocd account update-password \
  --account chandika \
  --current-password "" \
  --new-password "YourSecurePass"



# if flag --account is omitted then Argo CD generates token for current user
argocd account generate-token --account <username>


Add user:
=========
kubectl edit configmap argocd-cm -n argocd

data:
  accounts.<username>: apiKey, login

Permission for the user:
=========================
kubectl edit configmap argocd-rbac-cm -n argocd

apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    # Role: Read-only for testt-project
    p, role:readonly-testt, applications, get, testt-project/*, allow
    p, role:readonly-testt, projects, get, testt-project, allow

    # Bind user 'chandika' to the role
    g, chandika, role:readonly-testt
  policy.default: role:readonly


Group syntax:
g, <user/group>, <role>
eg: g, chandika, role:readonly-testt

Policy syntax:
p, <role/user/group>, <resource>, <action>, <object>, <effect>
eg: p, role:readonly-testt, applications, get, testt-project/*, allow


kubectl delete application testt-app -n argocd
kubectl delete appproject testt-project -n argocd


1️⃣ clusterResourceWhitelist
====================
Controls cluster-scoped resources.

These are Kubernetes objects that are not bound to a namespace.

Examples:

Namespace, ClusterRole, ClusterRoleBinding, PersistentVolume

If you leave this empty ([]) → The project cannot create any cluster-wide resources.
Useful for preventing a project from accidentally modifying cluster-level security, storage, or API definitions.

2️⃣ namespaceResourceWhitelist

Controls namespace-scoped resources.

These are Kubernetes objects that exist inside a specific namespace.

Examples: Deployment, Service, ConfigMap, Secret

If you allow only Deployment here → The project can only create Deployments in its target namespace, and cannot create Services, Secrets, etc.