# Canary Deployment

# Prerequisite

1. Install argo cd follow argocd-installation.md
2.  Install Argo Roll out follow argorollout-installation.md


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

1. create a file named application.yaml and make sure to verify repoURL matches the repositry which you cloned above.

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
## Modify the guestbook-rollout.yaml for deploying the version for the docker image.

1. Edit the file guestbook-rollout.yaml, change image: udemykcloud534/guestbook:green to image: udemykcloud534/guestbook:blue
2.  Access the loadbalancer dns
```
kubectl get ingress -A 
```








