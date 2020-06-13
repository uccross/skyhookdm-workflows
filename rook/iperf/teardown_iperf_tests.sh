#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config
kubectl delete -f ./iperf/server.yml
kubectl delete -f ./iperf/client.yml
