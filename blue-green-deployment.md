# Argo Rollout using blue-green deployment

## Prequisite
1. Argocd installation, follow argocd-installation.md
2. Argo Rollout installation, follow argo-rollout.md

## Blue green deployment

1. Install ingress controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```
2. Create a repositry name argo-rollout-guestbook-blue-green and clone it into local

3. Create a file name guestbook-rollout.yaml with the below code

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
      autoPromotionEnabled: false
      scaleDownDelaySeconds: 300
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
