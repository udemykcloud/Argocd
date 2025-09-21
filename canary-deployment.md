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
```


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
```
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
sudo chmod +x /usr/local/bin/kubectl-argo-rollouts
```

## Install Ingress controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```

## create argo rollout yaml file

1. Create a repositry name guestbook-rollout and clone it into local
2. Create a file name guestbook-rollout.yaml with the below code
```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook-ui
  namespace: default
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
    canary:
      steps:
        - setWeight: 20
        - pause: {}
        - setWeight: 50
        - pause: {}
        - setWeight: 100
      canaryService: guestbook-ui-canary
      stableService: guestbook-ui
      trafficRouting:
        nginx:
          stableIngress: guestbook-ui-ingress
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
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: guestbook-ui-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/canary: "false"
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

## create application

1. create a file named application.yaml

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-rollout
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/udemykcloud/argo-rollout-guestbook-demo.git
    path: guestbook-rollout
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated: {}
```
2. apply the application.yaml 

```
kubectl apply -f application.yaml
```
3. Access the loadbalancer dns

```
kubectl get ingress -A
```







