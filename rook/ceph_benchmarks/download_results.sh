#!/bin/bash
set -eu

mkdir -p ./ceph_benchmarks/results

pod=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")

for io_depth in ${IO_DEPTH[@]};
do
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/write.json > ./ceph_benchmarks/results/write-$io_depth.json
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/seq.json   > ./ceph_benchmarks/results/seq-$io_depth.json
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/rand.json  > ./ceph_benchmarks/results/rand-$io_depth.json
done

osd_count=$(kubectl exec -n "$NAMESPACE" "$pod" -- ls -f /tmp/ | grep -c osd)
for (( i=0; i<$osd_count; i++ )); do
    kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/osd.$i.json > ./ceph_benchmarks/results/osd.$i.json
done
