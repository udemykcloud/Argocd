## delete the resources in the eks cluster

1. delete the ingress resources 
```
kubectl get ingress -A
kubectl delete ingress -n <namespace> <ingress name>
```
2. delete the load balancer
```
aws elbv2 describe-load-balancers --region us-east-1
aws elbv2 delete-load-balancer --load-balancer-arn  <load-balancer-arn>
```
3. delete the cluster
```
terraform destory -auto-approve
```


