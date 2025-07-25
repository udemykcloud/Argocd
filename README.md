# Argocd


## Set up EKS Cluster with eksctl

* eksctl – A simple, dedicated EKS cluster management tool. Installation (https://eksctl.io/installation/)

* AWS CLI + kubectl (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

# Prerequiste

* VPC Setup for EKS cluster
  
-> <img width="1510" height="825" alt="Screenshot 2025-07-25 at 1 40 49 PM" src="https://github.com/user-attachments/assets/757150e5-5a00-441a-982e-f48b555c0018" />

-> use the s3 path and create a stack
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





