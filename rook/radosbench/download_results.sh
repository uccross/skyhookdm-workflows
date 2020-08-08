#!/bin/bash
set -eu

mkdir -p ./radosbench/results

pod=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")

for io_depth in ${IO_DEPTH[@]};
do
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/write.json > ./radosbench/results/write-$io_depth.json
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/seq.json   > ./radosbench/results/seq-$io_depth.json
kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/rand.json  > ./radosbench/results/rand-$io_depth.json
done

osd_count=$(kubectl exec -n "$NAMESPACE" "$pod" -- ls -f /tmp/ | grep -c osd)
for (( i=0; i<$osd_count; i++ )); do
    kubectl exec -n "$NAMESPACE" "$pod" -- cat /tmp/osd.$i.json > ./radosbench/results/osd.$i.json
done
