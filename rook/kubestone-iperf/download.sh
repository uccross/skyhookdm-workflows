#!/bin/bash
set -ex 

export KUBECONFIG=./kubeconfig/config

# find out the server pod
POD=$(kubectl get pod -n kubestone -l iperf-mode=server -o jsonpath="{.items[0].metadata.name}")

# download the iperf server logs
kubectl logs -n kubestone $POD > ./kubestone-iperf/results
