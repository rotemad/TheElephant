# RUN THIS SCRIPT ONLY AFTER THE VALUES CHANGES (as described in the HowTo)
kubectl apply -f aws-auth-cm.yaml
kubectl apply -f coredns-ConfigMap.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="jrlBUPF89ipG6nVorTPL5zYy92/jGn4jWpSeX3zcAy8="
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install consul hashicorp/consul -f consul-values.yaml