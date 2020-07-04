#!/bin/bash
set -eu

count=0
while [ "$(kubectl get pod -n kubestone -l iperf-mode=client -o jsonpath="{.items[0].status.phase}")" != "Succeeded" ]; 
do 
if [ $count == 30 ]; then
    exit 1
fi
echo "waiting for client pod to complete";
sleep 5
count=$(( count + 1 ))
done

pod=$(kubectl get pod -n kubestone -l iperf-mode=client -o jsonpath="{.items[0].metadata.name}")
kubectl logs -n kubestone $pod > ./kubestone_iperf/results
