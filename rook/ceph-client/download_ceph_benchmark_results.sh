#!/bin/bash
set -eux

mkdir -p ./results

export KUBECONFIG=./kubeconfig/config
pod_name=$(kubectl get pod -l app=ceph-client -o jsonpath="{.items[0].metadata.name}")

kubectl exec "$pod_name" -- cat /tmp/write.json > ./results/write.json
kubectl exec "$pod_name" -- cat /tmp/seq.json > ./results/seq.json
kubectl exec "$pod_name" -- cat /tmp/rand.json > ./results/rand.json

osd_count=$(kubectl exec "$pod_name" -- ls -f /tmp/ | grep -c osd)
for (( i=0; i<$osd_count; i++ )); do
    kubectl exec "$pod_name" -- cat /tmp/osd.$i.json > ./results/osd.$i.json
done
