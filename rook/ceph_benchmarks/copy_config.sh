#!/bin/bash
set -eu

count=0
while [ "$(kubectl get pod -n kubestone -l app=ceph-benchmarks -o jsonpath="{.items[0].status.phase}")" != "Running" ];
do
if [ $count == 10 ]; then
    exit 1
fi
echo "waiting for pod to comeup";
sleep 5
count=$(( count + 1 ))
done

pod=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")
kubectl cp -n "$NAMESPACE" ./cephconfig/ceph.conf "$NAMESPACE"/$pod:/etc/ceph/ceph.conf
kubectl cp -n "$NAMESPACE" ./cephconfig/keyring "$NAMESPACE"/$pod:/etc/ceph/keyring
