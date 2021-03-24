#!/bin/bash
# RUN THIS SCRIPT ONLY AFTER THE VALUES CHANGES (as described in the HowTo)
kubectl apply -f aws-auth-cm.yaml
kubectl apply -f coredns.yaml
kubectl apply -f svc.yaml
kubectl apply -f deployment.yaml
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="jrlBUPF89ipG6nVorTPL5zYy92/jGn4jWpSeX3zcAy8="
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install consul hashicorp/consul -f consul-values.yaml
helm install my-prometheus prometheus-community/prometheus --version 13.6.0 -f prometheus-values.yaml
kubectl apply -f filebeat.yaml
""
echo "Install Completed"