#!/bin/bash
set -eux

count=0
status=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].status.phase}")
while [ "$status" != "Running" ]; do 
if [ count == 10 ]; then
    exit 1
fi
echo "waiting for pod to comeup";
count=$(( count + 1 ))
sleep 5
status=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].status.phase}")
done

pod=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")
kubectl cp -n "$NAMESPACE" ./cephconfig/ceph.conf "$NAMESPACE"/$pod:/etc/ceph/ceph.conf
kubectl cp -n "$NAMESPACE" ./cephconfig/keyring "$NAMESPACE"/$pod:/etc/ceph/keyring
