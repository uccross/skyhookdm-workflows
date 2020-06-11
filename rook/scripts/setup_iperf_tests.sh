#!/bin/bash
set -eu

export KUBECONFIG=/workspace/kubeconfig/config

kubectl apply -f iperf/server.yml
sleep 5
pod_name=$(kubectl get pod -l app=iperf-server -o jsonpath="{.items[0].metadata.name}")
pod_host=$(kubectl get pod $pod_name --template={{.status.podIP}})

cp iperf/client.yml iperf/client.temp.yml
sed -i "s/__ip__/$pod_host/g" iperf/client.temp.yml
kubectl create -f iperf/client.temp.yml
rm iperf/client.temp.yml

result=$(kubectl logs $pod_name)
while [ -z "$result" ]; do
  result=$(kubectl logs $pod_name)
done

echo $result > /workspace/results/iperf-results.txt
