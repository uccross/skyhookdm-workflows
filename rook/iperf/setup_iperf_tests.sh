#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config

kubectl apply -f ./iperf/server.yml
sleep 5
pod_name=$(kubectl get pod -l app=iperf-server -o jsonpath="{.items[0].metadata.name}")
pod_host=$(kubectl get pod $pod_name --template={{.status.podIP}})

cp ./iperf/client.yml ./iperf/client.temp.yml
sed -i "s/__target__/$pod_host/g" ./iperf/client.temp.yml
sed -i "s/__replicas__/$replicas/g" ./iperf/client.temp.yml
kubectl create -f ./iperf/client.temp.yml
rm ./iperf/client.temp.yml

result=$(kubectl logs $pod_name)
while true; do
  result=$(kubectl logs $pod_name)
  echo "$result" > ./results/iperf-results.txt
  line_count=$(cat ./results/iperf-results.txt | wc -l)
  if [ "$line_count"  -eq "$replicas" ]; then
    break;
  fi
done
