#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config

replicas=2

for ((i = 0 ; i < $replicas ; i++)); do
  pod_name=$(kubectl get pod -l app=dd-client -o jsonpath="{.items[$i].metadata.name}")
  files=$(kubectl exec "$pod_name" -- ls /tmp | grep 'dd-s*')
  arr=(`echo ${files}`);
  for file in "${arr[@]}"
  do
    kubectl exec $pod_name -- cat /tmp/$file > ./results/$file
  done
done
