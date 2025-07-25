# Argocd


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

## Kustomize 

![handwriting_20250725_172922_via_10015_io](https://github.com/user-attachments/assets/d1324605-dbf9-493a-bae0-baa9fea955ef)








