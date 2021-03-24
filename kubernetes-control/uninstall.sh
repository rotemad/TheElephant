#!/bin/bash
helm uninstall my-prometheus
helm uninstall consul
kubectl delete -f filebeat.yaml
kubectl delete -f svc.yaml
kubectl delete -f deployment.yaml
""
echo "Uninstall Completed"