#!/bin/bash
set -eux

export KUBECONFIG=./kubeconfig/config
mkdir -p ./results

replicas=2

for ((i = 0 ; i < $replicas ; i++)); do
  pod_name=$(kubectl get pod -l app=dd-client -o jsonpath="{.items[$i].metadata.name}")
  pod_node=$(kubectl get pod $pod_name --template={{.spec.nodeName}})
  files=$(kubectl exec "$pod_name" -- ls /tmp | grep 'dd-s*')
  arr=(`echo ${files}`);
  for file in "${arr[@]}"
  do
    kubectl exec $pod_name -- cat /tmp/$file > ./results/$file
    mv ./results/$file ./results/$file-$pod_node
  done
done
