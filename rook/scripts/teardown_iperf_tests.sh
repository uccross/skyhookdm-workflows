#!/bin/bash
set -eu

export KUBECONFIG=/workspace/kubeconfig/config
kubectl delete -f ./iperf/server.yml
kubectl delete -f ./iperf/client.yml
