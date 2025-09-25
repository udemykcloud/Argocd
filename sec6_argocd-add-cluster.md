# Adding clusters to ArgoCD
## 1.Login to Argo CD

Make sure that you have updated the cluster details to the kubeconfig file and logged into Argo CD using Argo CD CLI, if not run the following command to log in to Argo CD.

```
argocd login <url>:<port> --username <username> --password <password>
```
With this command, you can log in to Argo CD using the username and password.

## 2: Get the Context of the Cluster

Run the following command to get the context from the kubeconfig file
```
kubectl config get-contexts -o name
```

## 3: Add the Cluster
```
argocd cluster add --kubeconfig <path-of-kubeconfig-file> --kube-context string <cluster-context> --name dev-cluster
```

Please go ahead and execute the commands below to add multiple clusters for different environments.
```
argocd cluster add --kubeconfig <path-of-kubeconfig-file> --kube-context string <cluster-context> --name dev-cluster
argocd cluster add --kubeconfig <path-of-kubeconfig-file> --kube-context string <cluster-context> --name staging-cluster
argocd cluster add --kubeconfig <path-of-kubeconfig-file> --kube-context string <cluster-context> --name prod-cluster
```
