#!/bin/bash
set -ex

export KUBECONFIG=./kubeconfig/config

# delete iperf3 test pods
kubectl delete -n kubestone -f ./kubestone/config/samples/perf_v1alpha1_iperf3.yaml
