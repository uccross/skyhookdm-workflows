#!/bin/bash
set -eu

mkdir -p ./ceph_benchmarks/results

pod=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")

kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/write.json > ./ceph_benchmarks/results/write.json
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/seq.json > ./ceph_benchmarks/results/seq.json
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/rand.json > ./ceph_benchmarks/results/rand.json

osd_count=$(kubectl exec -n "$NAMESPACE" "$pod" -- ls -f /tmp/ | grep -c osd)
for (( i=0; i<$osd_count; i++ )); do
    kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/osd.$i.json > ./ceph_benchmarks/results/osd.$i.json
done
