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
kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "LoadBalancer"}}'\

kubectl -n argocd get svc argocd-server

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

************************************************************************************************************************************************

## ArgoCD Architecture
ArgoCD is designed as a Kubernetes-native tool that simplifies continuous delivery using the GitOps approach. Its architecture consists of key components that work together to monitor, manage, and deploy applications. Below is a simple breakdown of its architecture, focusing on the core elements, how it integrates with Kubernetes, and its sync policies and reconciliation process.
Application Controller, API Server, and Repository Server

* Application Controller: This is the core component that continuously monitors the state of applications. It compares the live state of applications running in the Kubernetes cluster with the desired state defined in the Git repository. If it detects any differences (called drift), it flags the application as OutOfSync and takes action based on configured policies.
* API Server: The API Server provides a way to interact with ArgoCD. It powers the web user interface (UI) and command-line interface (CLI), allowing users to view application status, trigger syncs, or manage configurations. It also handles authentication and authorization, integrating with SSO providers like OIDC, LDAP, or GitHub.
* Repository Server: This component fetches and processes the application configurations stored in Git repositories. It supports various formats like YAML, Helm charts, Kustomize, or Jsonnet, and generates the Kubernetes manifests needed for deployment.

## ArgoCD as a Kubernetes Extension


ArgoCD is built as a Kubernetes controller, meaning it runs natively within a Kubernetes cluster and uses Kubernetes APIs to manage resources. It’s installed in a dedicated namespace (typically argocd) and leverages Kubernetes custom resources to define and track applications. This tight integration allows ArgoCD to:

Monitor and manage applications as Kubernetes resources.
Scale with the cluster, handling multiple applications and environments efficiently.
Work seamlessly with existing Kubernetes tools and workflows, making it a natural fit for teams already using Kubernetes.

## Sync Policies and Reconciliation Process

ArgoCD uses a reconciliation loop to ensure the live state of applications matches the desired state in the Git repository. Here's how it works:

Sync Policies: These define how ArgoCD handles synchronization when differences are detected:

* Manual Sync: Users manually trigger synchronization via the UI or CLI to apply changes from the Git repository.
Automated Sync: ArgoCD automatically applies changes from the Git repository to the cluster whenever updates are detected, reducing manual intervention.
* Sync Options: Policies can include settings like pruning (removing resources no longer in Git), self-healing (reverting unauthorized changes), or selective syncing (applying specific resources).


Reconciliation Process: The Application Controller periodically checks the live state against the Git-defined state. If they differ:

ArgoCD identifies the discrepancies (e.g., missing resources, incorrect configurations).
It applies the necessary changes to align the cluster with the Git repository, based on the sync policy.
It supports advanced rollout strategies like blue/green or canary deployments through sync hooks (PreSync, Sync, PostSync).


Visualization and Reporting: ArgoCD’s UI and CLI provide real-time insights into the sync status, showing which applications are in sync, out of sync, or degraded, along with detailed logs and audit trails.

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

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > password.txt
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

argocd cluster add arn:aws:eks:ap-southeast-1:215959898119:cluster/argocd
```

```

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml

```
```
argocd app create guestbook-rollout \
  --repo https://github.com/udemykcloud/argo-rollout-guestbook-demo.git \
  --path guestbook-rollout \
  --dest-server https://E86C8EA3F5648370F9E82266EF5404E5.gr7.ap-south-1.eks.amazonaws.com \
  --dest-namespace default \
  --sync-policy automated

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


* Deploy the guestbook rollout 
```
argocd app create guestbook-rollout-blue-green \
  --repo https://github.com/udemykcloud/argo-rollout-guestbook-blue-green.git \
  --path Guestbook-Rollout \
  --dest-server https://8591E3CED9235F9806846D8A7D48AA17.gr7.ap-south-1.eks.amazonaws.com\
  --dest-namespace default \
  --sync-policy automated
application 'guestbook-rollout-blue-green' created

argocd app sync guestbook-rollout
```
<img width="1512" height="857" alt="Screenshot 2025-08-03 at 8 02 40 AM" src="https://github.com/user-attachments/assets/ab015f55-6ce3-4183-aac6-a6b3fa58d9ff" />

```
kubectl get rollout guestbook-ui -n default
kubectl get pods -n default -l app=guestbook-ui
kubectl get svc guestbook-ui guestbook-ui-canary -n default
kubectl get ingress guestbook-ui-ingress -n default
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
guestbook-ui   3         3         3            3           4m26s
NAME                            READY   STATUS    RESTARTS   AGE
guestbook-ui-69b5f444f6-bnzs8   1/1     Running   0          110s
guestbook-ui-69b5f444f6-jm6nb   1/1     Running   0          110s
guestbook-ui-69b5f444f6-z4cvr   1/1     Running   0          110s
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
guestbook-ui          ClusterIP   172.20.213.255   <none>        80/TCP    11m
guestbook-ui-canary   ClusterIP   172.20.69.232    <none>        80/TCP    11m
NAME                   CLASS   HOSTS   ADDRESS                                                                          PORTS   AGE
guestbook-ui-ingress   nginx   *       ad4f4512b69764ce584fa54e2963ac58-2d903841f319d5b3.elb.ap-south-1.amazonaws.com   80      11m

```
## Test the blue version of the app



<img width="1512" height="900" alt="Screenshot 2025-08-03 at 8 04 16 AM" src="https://github.com/user-attachments/assets/fff08d6f-1427-4c04-94fa-276d6081131c" />

## Perform Blue green deployment

Update Manifest:
Edit guestbook-rollout.yaml to use image: udemykcloud534/guestbook:green

```
spec:
  template:
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
```

* Monitor 
```

Name:            guestbook-ui
Namespace:       default
Status:          ॥ Paused
Message:         BlueGreenPause
Strategy:        BlueGreen
Images:          udemykcloud534/guestbook:blue (stable, active)
                 udemykcloud534/guestbook:green (preview)
Replicas:
  Desired:       3
  Current:       6
  Updated:       3
  Ready:         3
  Available:     3

NAME                                      KIND        STATUS     AGE  INFO
⟳ guestbook-ui                            Rollout     ॥ Paused   29m  
├──# revision:2                                                       
│  └──⧉ guestbook-ui-7fb494c77f           ReplicaSet  ✔ Healthy  21s  preview
│     ├──□ guestbook-ui-7fb494c77f-6cg6p  Pod         ✔ Running  21s  ready:1/1
│     ├──□ guestbook-ui-7fb494c77f-tps2h  Pod         ✔ Running  21s  ready:1/1
│     └──□ guestbook-ui-7fb494c77f-w2cgh  Pod         ✔ Running  21s  ready:1/1
└──# revision:1                                                       
   └──⧉ guestbook-ui-69b5f444f6           ReplicaSet  ✔ Healthy  27m  stable,active
      ├──□ guestbook-ui-69b5f444f6-bnzs8  Pod         ✔ Running  26m  ready:1/1
      ├──□ guestbook-ui-69b5f444f6-jm6nb  Pod         ✔ Running  26m  ready:1/1
      └──□ guestbook-ui-69b5f444f6-z4cvr  Pod         ✔ Running  26m  ready:1/1


```
## Perform Blue-Green Deployment:

```
kubectl edit ingress guestbook-ui-ingress -n default 
ingress.networking.k8s.io/guestbook-ui-ingress edited
ranjiniganeshan@Ranjinis-MacBook-Pro udemy % kubectl argo rollouts promote guestbook-ui -n default
rollout 'guestbook-ui' promoted
ranjiniganeshan@Ranjinis-MacBook-Pro udemy % 

```
## Green version is rolled out.

<img width="1509" height="651" alt="Screenshot 2025-08-04 at 8 49 01 PM" src="https://github.com/user-attachments/assets/eee9421b-4513-4783-81c3-5027ca40ec52" />


## Minikube Installation

Preq
**********************************************************************************************************************************************

* Docker Desktop installed on your machine.

* Docker development tools enabled inside Visual Studio.
**********************************************************************************************************************************************

```
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  124M  100  124M    0     0  2862k      0  0:00:44  0:00:44 --:--:-- 5373k
ranjiniganeshan@Ranjinis-MacBook-Pro bin % sudo chmod +x minikube-darwin-arm64
ranjiniganeshan@Ranjinis-MacBook-Pro bin % sudo mv minikube-darwin-arm64 /usr/local/bin/minikube
ranjiniganeshan@Ranjinis-MacBook-Pro bin % minikube version  
minikube version: v1.36.0
commit: f8f52f5de11fc6ad8244afac475e1d0f96841df1-dirty
```

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

```
minikube start --driver=docker
😄  minikube v1.36.0 on Darwin 15.4.1 (arm64)
✨  Using the docker driver based on user configuration
📌  Using Docker Desktop driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.47 ...
💾  Downloading Kubernetes v1.33.1 preload ...
    > gcr.io/k8s-minikube/kicbase...:  463.69 MiB / 463.69 MiB  100.00% 3.75 Mi
    > preloaded-images-k8s-v18-v1...:  327.15 MiB / 327.15 MiB  100.00% 1.65 Mi
🔥  Creating docker container (CPUs=2, Memory=4000MB) ...
🐳  Preparing Kubernetes v1.33.1 on Docker 28.1.1 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

## argocd installation process in minikube
```
kubectl create namespace argocd
namespace/argocd created
ranjiniganeshan@Ranjinis-MacBook-Pro bin % kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
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
ranjiniganeshan@Ranjinis-MacBook-Pro bin % kubectl get pods -n argocd
NAME                                                READY   STATUS              RESTARTS   AGE
argocd-application-controller-0                     0/1     ContainerCreating   0          20s
argocd-applicationset-controller-655cc58ff8-hc9lz   0/1     ContainerCreating   0          21s
argocd-dex-server-7d9dfb4fb8-bc5zb                  0/1     Init:0/1            0          21s
argocd-notifications-controller-6c6848bc4c-k68g9    0/1     ContainerCreating   0          21s
argocd-redis-656c79549c-4w6zr                       0/1     Init:0/1            0          21s
argocd-repo-server-856b768fd9-gwff5                 0/1     Init:0/1            0          21s
argocd-server-99c485944-bq6d7                       0/1     ContainerCreating   0          21s
ranjiniganeshan@Ranjinis-MacBook-Pro bin % kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          2m27s
argocd-applicationset-controller-655cc58ff8-hc9lz   1/1     Running   0          2m28s
argocd-dex-server-7d9dfb4fb8-bc5zb                  1/1     Running   0          2m28s
argocd-notifications-controller-6c6848bc4c-k68g9    1/1     Running   0          2m28s
argocd-redis-656c79549c-4w6zr                       1/1     Running   0          2m28s
argocd-repo-server-856b768fd9-gwff5                 1/1     Running   0          2m28s
argocd-server-99c485944-bq6d7                       1/1     Running   0          2m28s
```

## Adding private repositories

###Generate a token in GitHub:

* Go to GitHub → Settings → Developer settings → Personal Access Tokens → Tokens (classic).
  Click Generate new token (classic).
* Give it a name, expiration date, and select:
repo (full control for private repos; for public repos, read:packages is enough)
Click Generate token and copy it.


## Verify once the permission ?
```
argocd repo add https://github.com/udemykcloud/guestbook \
  --username udemykcloud \
  --password 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
Repository 'https://github.com/udemykcloud/guestbook' added

```
## Using helm deploy to multiple clusters

## Preq for deploying on multiple eks clusters. 


* create eks cluster using eksctl . Use the config available in dev-cluster.yaml and prod-cluster.yaml
```
eksctl create cluster -f /Users/ranjiniganeshan/udemy/Argocd/prod-cluster.yaml
eksctl create cluster -f /Users/ranjiniganeshan/udemy/Argocd/dev-cluster.yaml
```

* install argocd
* install argo rollout
* install ingress



* Argocd  Install
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

* Argo Rollout install

```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```
* Access argo cd using loadbalancer service

```
kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "LoadBalancer"}}'
kubectl -n argocd get svc argocd-server
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > password_helm.txt

```


## Adding prod cluster to argocd 

## configure ArgoCD to manage the external production cluster

* Argo Rollout install

```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml
```
* Add repository

```
argocd login af08479d59d704ecca8e778ccb12a455-1020298881.ap-south-1.elb.amazonaws.com
WARNING: server certificate had error: tls: failed to verify certificate: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
Username: admin
Password: 
'admin:login' logged in successfully
Context 'af08479d59d704ecca8e778ccb12a455-1020298881.ap-south-1.elb.amazonaws.com' updated
ranjiniganeshan@Ranjinis-MacBook-Pro argocd-application % argocd repo add https://github.com/udemykcloud/guestbook-ui.git 
Repository 'https://github.com/udemykcloud/guestbook-ui.git' added

```

ranjiniganeshan@Ranjinis-MacBook-Pro udemy % argocd cluster list
SERVER                                                                     NAME                 VERSION  STATUS   MESSAGE                                                  PROJECT
https://59A7267E233CC42B85C27324FB9E3379.gr7.ap-south-1.eks.amazonaws.com  prod-argocd-cluster           Unknown  Cluster has no applications and is not being monitored.  
https://kubernetes.default.svc                                             in-cluster                    Unknown  Cluster has no applications and is not being monitored. 


argocd cluster add ranjini@prod-argocd-cluster.ap-south-1.eksctl.io
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `ranjini@prod-argocd-cluster.ap-south-1.eksctl.io` with full cluster level privileges. Do you want to continue [y/N]? y
{"level":"info","msg":"ServiceAccount \"argocd-manager\" already exists in namespace \"kube-system\"","time":"2025-08-21T20:45:34+05:30"}
{"level":"info","msg":"ClusterRole \"argocd-manager-role\" updated","time":"2025-08-21T20:45:34+05:30"}
{"level":"info","msg":"ClusterRoleBinding \"argocd-manager-role-binding\" updated","time":"2025-08-21T20:45:34+05:30"}
{"level":"info","msg":"Created bearer token secret for ServiceAccount \"argocd-manager\"","time":"2025-08-21T20:45:35+05:30"}
Cluster 'https://59A7267E233CC42B85C27324FB9E3379.gr7.ap-south-1.eks.amazonaws.com' added

kubectl config use-context prod-cluster

argocd cluster list

```

Add prod eks to dev argo cd 

```
argocd cluster add arn:aws:eks:ap-south-1:215959898119:cluster/prod3-argocd-cluster --name ranjini@prod3-argocd-cluster.ap-south-1.eksctl.io
```

kubectl apply -f https://github.com/udemykcloud/helm/blob/main/gitops-repo/environments/dev/application.yaml
kubectl apply -f https://github.com/udemykcloud/helm/blob/main/gitops-repo/environments/prod/application.yaml

* Access guestbook UI using the laodbalancer for dev and prod using dns prod.systemdesigns.xyz after configuring the cname.

**********************************************************************************************************************************************
Argo Workflow

Step 1: create a eks cluster
```
eksctl create cluster -f /Users/ranjiniganeshan/udemy/Argocd/dev-cluster.yaml
2025-09-01 15:27:34 [ℹ]  eksctl version 0.212.0
2025-09-01 15:27:34 [ℹ]  using region us-east-1
2025-09-01 15:27:34 [!]  Amazon EKS will no longer publish EKS-optimized Amazon Linux 2 (AL2) AMIs after November 26th, 2025. Additionally, Kubernetes version 1.32 is the last version for which Amazon EKS will release AL2 AMIs. From version 1.33 onwards, Amazon EKS will continue to release AL2023 and Bottlerocket based AMIs. The default AMI family when creating clusters and nodegroups in Eksctl will be changed to AL2023 in the future.
2025-09-01 15:27:36 [ℹ]  setting availability zones to [us-east-1c us-east-1f]
2025-09-01 15:27:36 [ℹ]  subnets for us-east-1c - public:192.168.0.0/19 private:192.168.64.0/19
2025-09-01 15:27:36 [ℹ]  subnets for us-east-1f - public:192.168.32.0/19 private:192.168.96.0/19
2025-09-01 15:27:37 [ℹ]  nodegroup "ng-1" will use "ami-05a4569e0854a2c75" [AmazonLinux2/1.32]
2025-09-01 15:27:38 [ℹ]  using Kubernetes version 1.32
2025-09-01 15:27:38 [ℹ]  creating EKS cluster "dev21-argocd-cluster" in "us-east-1" region with un-managed nodes
2025-09-01 15:27:38 [ℹ]  1 nodegroup (ng-1) was included (based on the include/exclude rules)
2025-09-01 15:27:38 [ℹ]  will create a CloudFormation stack for cluster itself and 1 nodegroup stack(s)
2025-09-01 15:27:38 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-1 --cluster=dev21-argocd-cluster'
2025-09-01 15:27:38 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "dev21-argocd-cluster" in "us-east-1"
2025-09-01 15:27:38 [ℹ]  CloudWatch logging will not be enabled for cluster "dev21-argocd-cluster" in "us-east-1"
2025-09-01 15:27:38 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=us-east-1 --cluster=dev21-argocd-cluster'
2025-09-01 15:27:38 [ℹ]  default addons metrics-server, vpc-cni, kube-proxy, coredns were not specified, will install them as EKS addons
2025-09-01 15:27:38 [ℹ]  
2 sequential tasks: { create cluster control plane "dev21-argocd-cluster", 
    2 sequential sub-tasks: { 
        2 sequential sub-tasks: { 
            1 task: { create addons },
            wait for control plane to become ready,
        },
        create nodegroup "ng-1",
    } 
}
2025-09-01 15:27:38 [ℹ]  building cluster stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:27:39 [ℹ]  deploying stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:28:09 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:28:41 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:29:42 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:30:43 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:31:44 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:32:45 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:33:52 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:34:53 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:35:55 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-cluster"
2025-09-01 15:36:00 [ℹ]  creating addon: metrics-server
2025-09-01 15:36:00 [ℹ]  successfully created addon: metrics-server
2025-09-01 15:36:02 [!]  recommended policies were found for "vpc-cni" addon, but since OIDC is disabled on the cluster, eksctl cannot configure the requested permissions; the recommended way to provide IAM permissions for "vpc-cni" addon is via pod identity associations; after addon creation is completed, add all recommended policies to the config file, under `addon.PodIdentityAssociations`, and run `eksctl update addon`
2025-09-01 15:36:02 [ℹ]  creating addon: vpc-cni
2025-09-01 15:36:02 [ℹ]  successfully created addon: vpc-cni
2025-09-01 15:36:03 [ℹ]  creating addon: kube-proxy
2025-09-01 15:36:04 [ℹ]  successfully created addon: kube-proxy
2025-09-01 15:36:04 [ℹ]  creating addon: coredns
2025-09-01 15:36:05 [ℹ]  successfully created addon: coredns
2025-09-01 15:38:09 [ℹ]  building nodegroup stack "eksctl-dev21-argocd-cluster-nodegroup-ng-1"
2025-09-01 15:38:12 [ℹ]  deploying stack "eksctl-dev21-argocd-cluster-nodegroup-ng-1"
2025-09-01 15:38:12 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-nodegroup-ng-1"
2025-09-01 15:38:43 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-nodegroup-ng-1"
2025-09-01 15:39:28 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-nodegroup-ng-1"
2025-09-01 15:41:20 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-nodegroup-ng-1"
2025-09-01 15:42:38 [ℹ]  waiting for CloudFormation stack "eksctl-dev21-argocd-cluster-nodegroup-ng-1"
2025-09-01 15:42:38 [ℹ]  waiting for the control plane to become ready
2025-09-01 15:42:38 [✔]  saved kubeconfig as "/Users/ranjiniganeshan/.kube/config"
2025-09-01 15:42:38 [ℹ]  no tasks
2025-09-01 15:42:38 [✔]  all EKS cluster resources for "dev21-argocd-cluster" have been created
2025-09-01 15:42:40 [ℹ]  nodegroup "ng-1" has 2 node(s)
2025-09-01 15:42:40 [ℹ]  node "ip-192-168-2-92.ec2.internal" is ready
2025-09-01 15:42:40 [ℹ]  node "ip-192-168-32-137.ec2.internal" is ready
2025-09-01 15:42:40 [ℹ]  waiting for at least 2 node(s) to become ready in "ng-1"
2025-09-01 15:42:40 [ℹ]  nodegroup "ng-1" has 2 node(s)
2025-09-01 15:42:40 [ℹ]  node "ip-192-168-2-92.ec2.internal" is ready
2025-09-01 15:42:40 [ℹ]  node "ip-192-168-32-137.ec2.internal" is ready
2025-09-01 15:42:40 [✔]  created 1 nodegroup(s) in cluster "dev21-argocd-cluster"
2025-09-01 15:42:41 [ℹ]  kubectl command should work with "/Users/ranjiniganeshan/.kube/config", try 'kubectl get nodes'
2025-09-01 15:42:41 [✔]  EKS cluster "dev21-argocd-cluster" in "us-east-1" region is ready

```
Step 2: 






















  











