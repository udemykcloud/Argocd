
## Argocd Deployment using helm

# Prerequisite

1.  Install argo cd follow argocd-installation.md
2.  Install Argo Roll out follow argorollout-installation.md


## Install Ingress controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```

## create argo rollout yaml file

1. Clone the repo
```
https://github.com/udemykcloud/helm.git
```
2. create namespace
```
kubectl create namespace dev
```
3. deploy the guestbook app using helm
```
kubectl apply -f helm/blob/main/gitops-repo/environments/dev/application.yaml
```
4. Access the guestbook-UI using the loadbalancer UI from the browser
```
kubectl get ingress -A 
```
