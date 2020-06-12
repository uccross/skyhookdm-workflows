#!/bin/bash
set -eux

mkdir -p /workspace/results

export KUBECONFIG=/workspace/kubeconfig/config
pod_name=$(kubectl get pod -l app=ceph-client -o jsonpath="{.items[0].metadata.name}")

kubectl exec "$pod_name" -- cat /tmp/write.json > /workspace/results/write.json
kubectl exec "$pod_name" -- cat /tmp/seq.json > /workspace/results/seq.json
kubectl exec "$pod_name" -- cat /tmp/rand.json > /workspace/results/rand.json

osd_count=$(kubectl exec "$pod_name" -- ls -f /tmp/ | grep -c osd)
for (( i=0; i<$osd_count; i++ )); do
    kubectl exec "$pod_name" -- cat /tmp/osd.$i.json > /workspace/results/osd.$i.json
done
