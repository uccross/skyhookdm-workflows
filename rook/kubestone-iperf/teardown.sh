#!/bin/bash
set -ex

export KUBECONFIG=./kubeconfig/config

# delete the iperf benchmark pods
kubectl delete -n kubestone -f ./kubestone-iperf/iperf.yaml
