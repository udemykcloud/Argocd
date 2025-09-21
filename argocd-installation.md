## Argo CD Installation

1. create namespace for argocd 

```
kubectl create namespace argocd
```
2. Install argocd 

```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
3. forward port to access argo ui
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
4. access the default password to log in to argocd ui
```
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
```
