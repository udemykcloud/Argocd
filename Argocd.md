# Argocd

***************************************************
## Mastering ArgoCD for Kubernetes Deployments
***************************************************

# Why ArgoCD?
Argo CD is a specialized tool that enhances Kubernetes deployments by implementing GitOps principles, offering automation, consistency, and scalability that native Kubernetes deployments alone cannot provide.

* GitOps Workflow for Automation
Benefit: Ensures declarative, version-controlled deployments, making rollbacks, audits, and collaboration easier compared to manual kubectl apply commands.

* Continuous Monitoring and Drift Detection

Benefit: By default, Kubernetes doesn’t automatically keep checking that your cluster always matches what you want. If you just use kubectl (the command line tool), you have to manually check if things have changed or broken.

* Simplified Rollbacks and History:
Kubernetes deployments support rollbacks (e.g., kubectl rollout undo), but they lack Git’s version control context, making it harder to track changes or collaborate across teams.
Multi-Cluster and Multi-Environment Management:

Argo CD can manage multiple Kubernetes clusters (e.g., dev, staging, prod) from a single control plane, using different Git repos or branches for each environment.

* Enhanced UI and Visualization
Kubernetes’ native tools (e.g., kubectl describe) are CLI-based and less intuitive for tracking complex deployments across teams.

* Integration with Helm and Other Tools
While Kubernetes supports Helm, applying and managing Helm charts manually or via scripts is less automated than Argo CD’s Git-driven approach.

## Why Are Kubernetes Deployments Alone Not Enough?
* Lack of Automation : Kubernetes deployments require manual kubectl commands or custom scripts to apply changes, which can lead to human errors or inconsistent processes

* No Built-in Drift Detection : Kubernetes doesn’t natively monitor for configuration drift. If someone modifies a resource directly (e.g., via kubectl edit), there’s no automatic way to detect or revert it.

* Limited Version Control : Kubernetes stores resource states in etcd database but doesn’t tie them to a version-controlled system like Git, making it hard to track changes or audit who did what.

* Complex Multi-Cluster Management : Managing multiple Kubernetes clusters (e.g., across AWS EKS regions) requires separate kubectl contexts and manual coordination.

* No Native GitOps Support: Kubernetes doesn’t inherently follow GitOps principles, requiring you to build custom pipelines for declarative, Git-driven deployments.



## Set up EKS Cluster with eksctl

* eksctl – A simple, dedicated EKS cluster management tool. Installation (https://eksctl.io/installation/)

* AWS CLI + kubectl (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

# Prerequiste

* VPC Setup for EKS cluster
  
-> <img width="1510" height="825" alt="Screenshot 2025-07-25 at 1 40 49 PM" src="https://github.com/user-attachments/assets/757150e5-5a00-441a-982e-f48b555c0018" />

-> use the s3 path and create a stack https://s3.amazonaws.com/aws-quickstart/quickstart-aws-vpc/templates/aws-vpc.template.yaml

<img width="1512" height="825" alt="Screenshot 2025-07-25 at 1 42 12 PM" src="https://github.com/user-attachments/assets/81d6c992-f9d8-4c8a-b128-e4825d9510b1" />

-> click next and create a cloudformation template.

<img width="1512" height="777" alt="Screenshot 2025-07-25 at 1 43 49 PM" src="https://github.com/user-attachments/assets/73351d44-45ad-4107-9906-9a4a736d33c7" />

-> Once the stack is created.

<img width="1511" height="784" alt="Screenshot 2025-07-25 at 2 01 20 PM" src="https://github.com/user-attachments/assets/5b50de57-91a4-462d-aa16-79e3638cce5d" />

* EKS cluster creation

-> create a access key
-> configure aws 
```
aws configure
AWS Access Key ID [****************36G5]: ***********************************
AWS Secret Access Key [****************Y+eg]: ***********************************
Default region name [us-east-1]: ap-south-1
Default output format [json]: 
```

-> create a cluster , after modifing vpc and subnet ID

``` eksctl create cluster -f cluster.yaml ```

Verify if the cluster is created.
```
eksctl create cluster -f cluster.yaml
2025-07-25 14:22:53 [ℹ]  eksctl version 0.167.0
2025-07-25 14:22:53 [ℹ]  using region ap-south-1
2025-07-25 14:22:54 [✔]  using existing VPC (vpc-0f0b671dd0cb25b84) and subnets (private:map[] public:map[ap-south-1a:{subnet-0971f6a6ba08019be ap-south-1a 10.0.128.0/20 0 } ap-south-1b:{subnet-08c94ae5b8da490b8 ap-south-1b 10.0.144.0/20 0 }])
2025-07-25 14:22:54 [!]  custom VPC/subnets will be used; if resulting cluster doesn't function as expected, make sure to review the configuration of VPC/subnets
2025-07-25 14:22:54 [ℹ]  nodegroup "public-ng-1" will use "ami-0d4e9299753d4aa4b" [AmazonLinux2/1.28]
2025-07-25 14:22:54 [ℹ]  using SSH public key "/Users/ranjiniganeshan/.ssh/id_rsa.pub" as "eksctl-argocd-nodegroup-public-ng-1-a8:a2:23:d6:4a:16:3d:b9:2d:34:5e:68:b7:3d:d0:a9" 
2025-07-25 14:22:54 [ℹ]  using Kubernetes version 1.28
2025-07-25 14:22:54 [ℹ]  creating EKS cluster "argocd" in "ap-south-1" region with un-managed nodes
2025-07-25 14:22:54 [ℹ]  1 nodegroup (public-ng-1) was included (based on the include/exclude rules)
2025-07-25 14:22:54 [ℹ]  will create a CloudFormation stack for cluster itself and 1 nodegroup stack(s)
2025-07-25 14:22:54 [ℹ]  will create a CloudFormation stack for cluster itself and 0 managed nodegroup stack(s)
2025-07-25 14:22:54 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-south-1 --cluster=argocd'
2025-07-25 14:22:54 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "argocd" in "ap-south-1"
2025-07-25 14:22:54 [ℹ]  CloudWatch logging will not be enabled for cluster "argocd" in "ap-south-1"
2025-07-25 14:22:54 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-south-1 --cluster=argocd'
2025-07-25 14:22:54 [ℹ]  
2 sequential tasks: { create cluster control plane "argocd", 
    2 sequential sub-tasks: { 
        wait for control plane to become ready,
        create nodegroup "public-ng-1",
    } 
}
2025-07-25 14:22:54 [ℹ]  building cluster stack "eksctl-argocd-cluster"
2025-07-25 14:22:55 [ℹ]  deploying stack "eksctl-argocd-cluster"
2025-07-25 14:23:25 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:23:56 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:24:56 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:25:57 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:26:57 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:27:58 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:28:58 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:29:58 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:30:59 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-cluster"
2025-07-25 14:33:02 [ℹ]  building nodegroup stack "eksctl-argocd-nodegroup-public-ng-1"
2025-07-25 14:33:02 [!]  subnets contain a mix of both local and availability zones
2025-07-25 14:33:02 [!]  subnets contain a mix of both local and availability zones
2025-07-25 14:33:03 [ℹ]  deploying stack "eksctl-argocd-nodegroup-public-ng-1"
2025-07-25 14:33:03 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-nodegroup-public-ng-1"
2025-07-25 14:33:33 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-nodegroup-public-ng-1"
2025-07-25 14:34:28 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-nodegroup-public-ng-1"
2025-07-25 14:36:23 [ℹ]  waiting for CloudFormation stack "eksctl-argocd-nodegroup-public-ng-1"
2025-07-25 14:36:23 [ℹ]  waiting for the control plane to become ready
2025-07-25 14:36:23 [✔]  saved kubeconfig as "/Users/ranjiniganeshan/.kube/config"
2025-07-25 14:36:23 [ℹ]  no tasks
2025-07-25 14:36:23 [✔]  all EKS cluster resources for "argocd" have been created
2025-07-25 14:36:24 [ℹ]  nodegroup "public-ng-1" has 2 node(s)
2025-07-25 14:36:24 [ℹ]  node "ip-10-0-134-208.ap-south-1.compute.internal" is ready
2025-07-25 14:36:24 [ℹ]  node "ip-10-0-156-199.ap-south-1.compute.internal" is ready
2025-07-25 14:36:24 [ℹ]  waiting for at least 2 node(s) to become ready in "public-ng-1"
2025-07-25 14:36:24 [ℹ]  nodegroup "public-ng-1" has 2 node(s)
2025-07-25 14:36:24 [ℹ]  node "ip-10-0-134-208.ap-south-1.compute.internal" is ready
2025-07-25 14:36:24 [ℹ]  node "ip-10-0-156-199.ap-south-1.compute.internal" is ready
2025-07-25 14:36:25 [ℹ]  kubectl command should work with "/Users/ranjiniganeshan/.kube/config", try 'kubectl get nodes'
2025-07-25 14:36:25 [✔]  EKS cluster "argocd" in "ap-south-1" region is ready
ranjiniganeshan@Ranjinis-MacBook-Pro udemy % kubectl get nodes -A
NAME                                          STATUS   ROLES    AGE     VERSION
ip-10-0-134-208.ap-south-1.compute.internal   Ready    <none>   4m29s   v1.28.15-eks-473151a
ip-10-0-156-199.ap-south-1.compute.internal   Ready    <none>   4m27s   v1.28.15-eks-473151a
```


# Argo CD  Installation

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

# ArgoCD CLI Installation

ArgoCD CLI
```
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd
```

# Log in to the ArgoCD server. Expose the ArgoCD API server using port forwarding
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

# Steps to Log into the ArgoCD UI

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > password.txt

* default username is admin

<img width="1507" height="903" alt="Screenshot 2025-07-25 at 3 50 19 PM" src="https://github.com/user-attachments/assets/fa4c1eab-17ce-4772-9488-9a4e799d1ae1" />

# Exposing argocd using loadbalancer

```
kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "LoadBalancer"}}'
service/argocd-server patched
ranjiniganeshan@Ranjinis-MacBook-Pro udemy % kubectl -n argocd get svc argocd-server
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP                                                                PORT(S)                      AGE
argocd-server   LoadBalancer   172.20.157.188   a7a762123a8d14c71956e975afab7fff-2020289002.ap-south-1.elb.amazonaws.com   80:30677/TCP,443:30757/TCP   51m

```

# Access argocd  UI using loadbalanacer name or External IP from the above output.
<img width="1511" height="904" alt="Screenshot 2025-07-25 at 4 31 04 PM" src="https://github.com/user-attachments/assets/0b026038-cede-43fd-95af-dd84053d0a3f" />


# Deploy the sample guestbook application on EKS using Argocd


* Set Context for argocd

```
aws eks --region ap-south-1 update-kubeconfig --name argocd
kubectl config current-context

Updated context arn:aws:eks:ap-south-1:215959898119:cluster/argocd in /Users/ranjiniganeshan/.kube/config
arn:aws:eks:ap-south-1:215959898119:cluster/argocd

argocd cluster add arn:aws:eks:ap-south-1:215959898119:cluster/argocd
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `arn:aws:eks:ap-south-1:215959898119:cluster/argocd` with full cluster level privileges. Do you want to continue [y/N]? y
INFO[0003] ServiceAccount "argocd-manager" created in namespace "kube-system" 
INFO[0003] ClusterRole "argocd-manager-role" created    
INFO[0004] ClusterRoleBinding "argocd-manager-role-binding" created 
INFO[0004] Created bearer token secret for ServiceAccount "argocd-manager" 
Cluster 'https://08CFE27D9DF7F8C856685B1B57903353.gr7.ap-south-1.eks.amazonaws.com' added

```

## Troubleshooting connecting to eks cluster

```
argocd login localhost:8080
WARNING: server certificate had error: tls: failed to verify certificate: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
Username: admin
Password: 
'admin:login' logged in successfully
Context 'localhost:8080' updated
ranjiniganeshan@Ranjinis-MacBook-Pro udemy % argocd cluster add arn:aws:eks:ap-south-1:215959898119:cluster/argocd
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `arn:aws:eks:ap-south-1:215959898119:cluster/argocd` with full cluster level privileges. Do you want to continue [y/N]? y
INFO[0002] ServiceAccount "argocd-manager" already exists in namespace "kube-system" 
INFO[0002] ClusterRole "argocd-manager-role" updated    
INFO[0002] ClusterRoleBinding "argocd-manager-role-binding" updated 
Cluster 'https://C3E7F917ACB77315439B17C40EB69E19.yl4.ap-south-1.eks.amazonaws.com' added

```

* deploy guestbook application

-> Deploy 
```
argocd app create guestbook \                                        
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path guestbook \
  --dest-server https://08CFE27D9DF7F8C856685B1B57903353.gr7.ap-south-1.eks.amazonaws.com \
  --dest-namespace default
application 'guestbook' created

```
-> Sync the app and verify the deplyment
```
argocd app sync guestbook
TIMESTAMP                  GROUP        KIND   NAMESPACE                  NAME    STATUS    HEALTH        HOOK  MESSAGE
2025-07-25T16:44:38+05:30            Service     default          guestbook-ui  OutOfSync  Missing              
2025-07-25T16:44:38+05:30   apps  Deployment     default          guestbook-ui  OutOfSync  Missing              
2025-07-25T16:44:38+05:30   apps  Deployment     default          guestbook-ui  OutOfSync  Missing              deployment.apps/guestbook-ui created
2025-07-25T16:44:38+05:30            Service     default          guestbook-ui  OutOfSync  Missing              service/guestbook-ui created

Name:               argocd/guestbook
Project:            default
Server:             https://08CFE27D9DF7F8C856685B1B57903353.gr7.ap-south-1.eks.amazonaws.com
Namespace:          default
URL:                https://a7a762123a8d14c71956e975afab7fff-2020289002.ap-south-1.elb.amazonaws.com/applications/guestbook
Source:
- Repo:             https://github.com/argoproj/argocd-example-apps.git
  Target:           
  Path:             guestbook
SyncWindow:         Sync Allowed
Sync Policy:        Manual
Sync Status:        Synced to  (f58c7ed)
Health Status:      Progressing

Operation:          Sync
Sync Revision:      f58c7ed8cfe28ad70701c5923fdbd0154388ea9f
Phase:              Succeeded
Start:              2025-07-25 16:44:38 +0530 IST
Finished:           2025-07-25 16:44:38 +0530 IST
Duration:           0s
Message:            successfully synced (all tasks run)

GROUP  KIND        NAMESPACE  NAME          STATUS  HEALTH  HOOK  MESSAGE
       Service     default    guestbook-ui  Synced                service/guestbook-ui created
apps   Deployment  default    guestbook-ui  Synced                deployment.apps/guestbook-ui created
ranjiniganeshan@Ranjinis-MacBook-Pro udemy % argocd app set guestbook --sync-policy automated --auto-prune --self-heal
ranjiniganeshan@Ranjinis-MacBook-Pro udemy % kubectl get pods,svc -n default
NAME                                READY   STATUS              RESTARTS   AGE
pod/guestbook-ui-7bb94b6878-r464v   0/1     ContainerCreating   0          21s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/guestbook-ui   ClusterIP   172.20.44.87   <none>        80/TCP    21s
service/kubernetes     ClusterIP   172.20.0.1     <none>        443/TCP   136m
```
-> Access the Guestbook Application using port forward
```
kubectl port-forward svc/guestbook-ui -n default 8081:80
Forwarding from 127.0.0.1:8081 -> 80
Forwarding from [::1]:8081 -> 80
Handling connection for 8081
Handling connection for 8081

```
<img width="1507" height="905" alt="Screenshot 2025-07-25 at 4 49 31 PM" src="https://github.com/user-attachments/assets/cd6e1537-5897-4a70-8e84-98f8e4cca01e" />

# Verify the guestbook deployment in argocd UI

<img width="1507" height="902" alt="Screenshot 2025-07-25 at 4 50 27 PM" src="https://github.com/user-attachments/assets/12d28fb1-a843-4ea4-b9d1-5010f0ce8337" />

# cleanup guestbook application
-> delete the guestbook app from argo cd  console 



## Kustomize 
![handwriting_20250725_173334_via_10015_io](https://github.com/user-attachments/assets/5f50c8f5-324e-4171-92a1-0be9ea40db23)

# Hands-On: Deploying kustomize-guestbook on an EKS Cluster on multiple environments.


<img width="1308" height="771" alt="Screenshot 2025-07-28 at 11 25 45 AM" src="https://github.com/user-attachments/assets/c1540ad8-0a83-49e4-ad24-3a7b0ea46bd7" />

## Apply the kustomize changes for guestbook app
```
kubectl kustomize . | kubectl apply -f -
service/kustomize-guestbook-ui created
deployment.apps/kustomize-guestbook-ui created 
```
```
kubectl  get all -A
NAMESPACE     NAME                                          READY   STATUS    RESTARTS   AGE
default       pod/kustomize-guestbook-ui-7bb94b6878-gkr8p   1/1     Running   0          34s
kube-system   pod/aws-node-2cgd7                            2/2     Running   0          34m
kube-system   pod/aws-node-t6wb7                            2/2     Running   0          34m
kube-system   pod/coredns-56b8d964f7-cmcpb                  1/1     Running   0          38m
kube-system   pod/coredns-56b8d964f7-pbtq7                  1/1     Running   0          38m
kube-system   pod/kube-proxy-ck2bb                          1/1     Running   0          34m
kube-system   pod/kube-proxy-vcxtg                          1/1     Running   0          34m

NAMESPACE     NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
default       service/kubernetes                  ClusterIP   172.20.0.1       <none>        443/TCP         39m
default       service/kustomize-guestbook-ui      ClusterIP   172.20.152.180   <none>        80/TCP          34s
kube-system   service/eks-extension-metrics-api   ClusterIP   172.20.16.225    <none>        443/TCP         39m
kube-system   service/kube-dns                    ClusterIP   172.20.0.10      <none>        53/UDP,53/TCP   38m

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/aws-node     2         2         2       2            2           <none>          38m
kube-system   daemonset.apps/kube-proxy   2         2         2       2            2           <none>          38m

NAMESPACE     NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/kustomize-guestbook-ui   1/1     1            1           34s
kube-system   deployment.apps/coredns                  2/2     2            2           38m

NAMESPACE     NAME                                                DESIRED   CURRENT   READY   AGE
default       replicaset.apps/kustomize-guestbook-ui-7bb94b6878   1         1         1       34s
kube-system   replicaset.apps/coredns-56b8d964f7                  2         2         2       38m
```
## cleanup the simple kustomize app 

```
kubectl get all -n default
NAME                                          READY   STATUS    RESTARTS   AGE
pod/kustomize-guestbook-ui-7bb94b6878-gkr8p   1/1     Running   0          34m

NAME                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/kubernetes               ClusterIP   172.20.0.1       <none>        443/TCP   73m
service/kustomize-guestbook-ui   ClusterIP   172.20.152.180   <none>        80/TCP    34m

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kustomize-guestbook-ui   1/1     1            1           34m

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/kustomize-guestbook-ui-7bb94b6878   1         1         1       34m

kubectl delete deployment kustomize-guestbook-ui -n default 
deployment.apps "kustomize-guestbook-ui" deleted

kubectl delete service kustomize-guestbook-ui -n default
service "kustomize-guestbook-ui" deleted

```

## Verify the cleanup is completed

```
kubectl get all -n default
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   74m
```

## Deploy Kustomize to multiple environments


* Apply from dev folder
```
kubectl create namespace dev
namespace/dev created
ranjiniganeshan@Ranjinis-MacBook-Pro dev % kubectl kustomize . | kubectl apply -f -
service/dev-guestbook-ui created
deployment.apps/dev-guestbook-ui created
```
* Verify the deployment in dev space

```
kubectl get all -n dev
NAME                                    READY   STATUS    RESTARTS   AGE
pod/dev-guestbook-ui-7bb94b6878-97zkd   1/1     Running   0          2m40s
pod/dev-guestbook-ui-7bb94b6878-b4vdq   1/1     Running   0          2m40s

NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/dev-guestbook-ui   ClusterIP   172.20.146.57   <none>        80/TCP    2m40s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dev-guestbook-ui   2/2     2            2           2m40s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/dev-guestbook-ui-7bb94b6878   2         2         2       2m40s
```

* Verify deloyment in prod namespace

```
kubectl get all -n prod
NAME                                     READY   STATUS    RESTARTS   AGE
pod/prod-guestbook-ui-7bb94b6878-bxhn7   1/1     Running   0          75s
pod/prod-guestbook-ui-7bb94b6878-r6ldb   1/1     Running   0          75s

NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/prod-guestbook-ui   ClusterIP   172.20.73.31   <none>        80/TCP    75s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prod-guestbook-ui   2/2     2            2           75s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/prod-guestbook-ui-7bb94b6878   2         2         2       75s

```
************************************************************************************
# Argo Rollouts
*************************************************************************************

## Canary Deployment

* Argo CD Installation

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
namespace/argocd created
customresourcedefinition.apiextensions.k8s.io/applications.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/applicationsets.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/appprojects.argoproj.io created
serviceaccount/argocd-application-controller created
serviceaccount/argocd-applicationset-controller created
serviceaccount/argocd-dex-server created
serviceaccount/argocd-notifications-controller created
serviceaccount/argocd-redis created
serviceaccount/argocd-repo-server created
serviceaccount/argocd-server created
role.rbac.authorization.k8s.io/argocd-application-controller created
role.rbac.authorization.k8s.io/argocd-applicationset-controller created
role.rbac.authorization.k8s.io/argocd-dex-server created
role.rbac.authorization.k8s.io/argocd-notifications-controller created
role.rbac.authorization.k8s.io/argocd-redis created
role.rbac.authorization.k8s.io/argocd-server created
clusterrole.rbac.authorization.k8s.io/argocd-application-controller created
clusterrole.rbac.authorization.k8s.io/argocd-applicationset-controller created
clusterrole.rbac.authorization.k8s.io/argocd-server created
rolebinding.rbac.authorization.k8s.io/argocd-application-controller created
rolebinding.rbac.authorization.k8s.io/argocd-applicationset-controller created
rolebinding.rbac.authorization.k8s.io/argocd-dex-server created
rolebinding.rbac.authorization.k8s.io/argocd-notifications-controller created
rolebinding.rbac.authorization.k8s.io/argocd-redis created
rolebinding.rbac.authorization.k8s.io/argocd-server created
clusterrolebinding.rbac.authorization.k8s.io/argocd-application-controller created
clusterrolebinding.rbac.authorization.k8s.io/argocd-applicationset-controller created
clusterrolebinding.rbac.authorization.k8s.io/argocd-server created
configmap/argocd-cm created
configmap/argocd-cmd-params-cm created
configmap/argocd-gpg-keys-cm created
configmap/argocd-notifications-cm created
configmap/argocd-rbac-cm created
configmap/argocd-ssh-known-hosts-cm created
configmap/argocd-tls-certs-cm created
secret/argocd-notifications-secret created
secret/argocd-secret created
service/argocd-applicationset-controller created
service/argocd-dex-server created
service/argocd-metrics created
service/argocd-notifications-controller-metrics created
service/argocd-redis created
service/argocd-repo-server created
service/argocd-server created
service/argocd-server-metrics created
deployment.apps/argocd-applicationset-controller created
deployment.apps/argocd-dex-server created
deployment.apps/argocd-notifications-controller created
deployment.apps/argocd-redis created
deployment.apps/argocd-repo-server created
deployment.apps/argocd-server created
statefulset.apps/argocd-application-controller created
networkpolicy.networking.k8s.io/argocd-application-controller-network-policy created
networkpolicy.networking.k8s.io/argocd-applicationset-controller-network-policy created
networkpolicy.networking.k8s.io/argocd-dex-server-network-policy created
networkpolicy.networking.k8s.io/argocd-notifications-controller-network-policy created
networkpolicy.networking.k8s.io/argocd-redis-network-policy created
networkpolicy.networking.k8s.io/argocd-repo-server-network-policy created
networkpolicy.networking.k8s.io/argocd-server-network-policy created

```
* Port forward to access ARGOCD UI

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

* Access argocd server using the UI https://localhost:8080/

* Install Argo Rollout with canary deployment

Argo Rollouts is a Kubernetes controller and set of Custom Resource Definitions (CRDs) that enable advanced deployment strategies like canary and blue-green deployments. Unlike standard Kubernetes Deployments, which use a RollingUpdate strategy, Argo Rollouts provides fine-grained control over traffic shifting and automated rollback based on metrics analysis. In a canary deployment, a new version of the application is gradually rolled out to a subset of users, allowing you to monitor its performance before fully promoting it.


```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
namespace/argo-rollouts created
customresourcedefinition.apiextensions.k8s.io/analysisruns.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/analysistemplates.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/clusteranalysistemplates.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/experiments.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/rollouts.argoproj.io created
serviceaccount/argo-rollouts created
clusterrole.rbac.authorization.k8s.io/argo-rollouts created
clusterrole.rbac.authorization.k8s.io/argo-rollouts-aggregate-to-admin created
clusterrole.rbac.authorization.k8s.io/argo-rollouts-aggregate-to-edit created
clusterrole.rbac.authorization.k8s.io/argo-rollouts-aggregate-to-view created
clusterrolebinding.rbac.authorization.k8s.io/argo-rollouts created
configmap/argo-rollouts-config created
secret/argo-rollouts-notification-secret created
service/argo-rollouts-metrics created
deployment.apps/argo-rollouts created
```


* Install Argo rollouts kubectl plugins

```
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
sudo chmod +x /usr/local/bin/kubectl-argo-rollouts
```

* Create and Sync ArgoCD Application
```

argocd login acdfefaa342dc4669a3a920690820f36-1215039150.ap-southeast-1.elb.amazonaws.com

aws eks --region ap-southeast-1 update-kubeconfig --name argocd
 1423  argocd cluster add arn:aws:eks:ap-southeast-1:215959898119:cluster/argocd

argocd app create guestbook-rollout \
  --repo https://github.com/udemykcloud/argo-rollout-guestbook-demo.git \
  --path guestbook-rollout \
  --dest-server https://E86C8EA3F5648370F9E82266EF5404E5.gr7.ap-south-1.eks.amazonaws.com \
  --dest-namespace default \
  --sync-policy automated
application 'guestbook-rollout' created
```

<img width="1509" height="892" alt="Screenshot 2025-07-29 at 4 05 11 PM" src="https://github.com/user-attachments/assets/1a9e9b3a-8d5c-4627-83fe-4ddad0434dbc" />




<img width="1214" height="551" alt="Screenshot 2025-07-29 at 5 19 06 PM" src="https://github.com/user-attachments/assets/d9127aa6-02d1-4ff7-8ba1-840fac402980" />


```
argocd app sync guestbook-rollout

argocd app sync guestbook-rollout
TIMESTAMP                  GROUP                    KIND   NAMESPACE                  NAME    STATUS   HEALTH        HOOK  MESSAGE
Name:            guestbook-ui
Namespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/5
  SetWeight:     20
  ActualWeight:  20
Images:          udemykcloud534/guestbook:blue (stable)
                 udemykcloud534/guestbook:green (canary)
Replicas:
  Desired:       3
  Current:       4
  Updated:       1
  Ready:         4
  Available:     4

NAME                                      KIND        STATUS     AGE  INFO
⟳ guestbook-ui                            Rollout     ॥ Paused   28m  
├──# revision:2                                                       
│  └──⧉ guestbook-ui-7fb494c77f           ReplicaSet  ✔ Healthy  67s  canary
│     └──□ guestbook-ui-7fb494c77f-7prts  Pod         ✔ Running  67s  ready:1/1
└──# revision:1                                                       
   └──⧉ guestbook-ui-69b5f444f6           ReplicaSet  ✔ Healthy  28m  stable
      ├──□ guestbook-ui-69b5f444f6-24q5t  Pod         ✔ Running  28m  ready:1/1
      ├──□ guestbook-ui-69b5f444f6-47d66  Pod         ✔ Running  28m  ready:1/1
      └──□ guestbook-ui-69b5f444f6-ktjx4  Pod         ✔ Running  28m  ready:1/1
```

<img width="1509" height="936" alt="Screenshot 2025-07-29 at 5 26 39 PM" src="https://github.com/user-attachments/assets/07f5ff0d-0416-44b9-ac1b-73f540db7e5a" />

## Argo Rollout Blue-Green Deployment

Blue-green deployment runs two versions of your app: the blue version guestbook:blue serves all traffic, while the green version guestbook:green is deployed but receives no traffic until you’re ready to switch. Once verified, you instantly switch all traffic to green, and blue is kept ready for rollback if needed.

# How Blue green deployment works

Blue Phase: 3 pods run blue, and the guestbook-ui service routes 100% traffic to them via the guestbook-ui-ingress.
Green Phase: Deploy 3 pods with green. The guestbook-ui-canary service points to green pods, but no traffic goes there yet.
Switch: When ready, Argo Rollouts updates the guestbook-ui service to point to green pods, instantly switching 100% traffic to green.
Rollback: If green fails, switch back to blue with kubectl argo rollouts abort guestbook-ui -n default.







  











