# Argo Image Updater

Install Argo-image updater controller in argocd namespace of the k8s cluster 

```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

Store the github secrets of the manifest repo as Argo Image Updater will update the manifests.
```
kubectl -n argocd create secret generic git-creds \
  --from-literal=username=xxxxxx \
  --from-literal=password=ghp_yyyyyy
```

### Update application.yaml manifest file with image updater annotations

```
metadata:
  annotations:
    argocd-image-updater.argoproj.io/git-branch: staging
    argocd-image-updater.argoproj.io/image-list: myimage=xxxxxx/vote
    argocd-image-updater.argoproj.io/myimage.allow-tags: regexp:^[0-9a-f]{7}$
    argocd-image-updater.argoproj.io/myimage.ignore-tags: latest, dev
    argocd-image-updater.argoproj.io/myimage.update-strategy: latest
    argocd-image-updater.argoproj.io/myimage.kustomize.image-name: schoolofdevops/vote
    argocd-image-updater.argoproj.io/myimage.force-update: "true"
    argocd-image-updater.argoproj.io/write-back-method: git:secret:argocd/git-creds
    argocd-image-updater.argoproj.io/write-back-target: "kustomization:../base"
```

Apply the application
```
kubectl apply -f staging-app.yaml
```

Application should sync the latest image


