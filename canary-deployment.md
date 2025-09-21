# Canary Deployment

## If Argo CD  is not installed previously, please follow the below steps
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

## Install Argo Roll out
1.  create namespace for argo- rollouts
```
kubectl create namespace argo-rollouts
````
2. install argo rollouts
```
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```
3. Install Argo rollouts kubectl plugins
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
sudo chmod +x /usr/local/bin/kubectl-argo-rollouts





