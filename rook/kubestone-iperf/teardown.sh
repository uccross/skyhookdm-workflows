#!/bin/bash
set -ex

export KUBECONFIG=./kubeconfig/config

# delete iperf3 tests
kubectl delete -n kubestone -f ./kubestone/config/samples/perf_v1alpha1_iperf3.yaml

