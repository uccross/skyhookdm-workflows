#!/bin/bash
set -eu

mkdir -p ./ceph_benchmarks/results

export KUBECONFIG=./kubeconfig/config
POD=$(kubectl get pod -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")

kubectl exec "$POD" -- cat /tmp/write.json > ./ceph_benchmarks/results/write.json
kubectl exec "$POD" -- cat /tmp/seq.json > ./ceph_benchmarks/results/seq.json
kubectl exec "$POD" -- cat /tmp/rand.json > ./ceph_benchmarks/results/rand.json

OSD_COUNT=$(kubectl exec "$POD" -- ls -f /tmp/ | grep -c osd)
for (( i=0; i<$OSD_COUNT; i++ )); do
    kubectl exec "$POD" -- cat /tmp/osd.$i.json > ./ceph_benchmarks/results/osd.$i.json
done
