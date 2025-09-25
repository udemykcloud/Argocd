
## Argocd Deployment using helm

# Prerequisite

1.  Install argo cd follow argocd-installation.md
2.  Install Argo Roll out follow argorollout-installation.md


## Install Ingress controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```

## create argo rollout yaml file

1. Create a repositry name argo-rollout-canary and clone it into local
2. Create a file name guestbook-rollout.yaml  within a folder named ** guestbook-rollout **  with the below code
