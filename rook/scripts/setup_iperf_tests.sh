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
while true; do
  result=$(kubectl logs $pod_name)
  echo "$result" > /workspace/results/iperf-results.txt
  line_count=$(cat /workspace/results/iperf-results.txt | wc -l)
  if [ "$line_count"  -eq 3 ]; then
    break;
  fi
done
