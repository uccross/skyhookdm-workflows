#!/bin/bash
set -ex

export KUBECONFIG=./kubeconfig/config

# start the iperf benchmark pods in kubestone namespace
kubectl create -n kubestone -f ./kubestone/config/samples/perf_v1alpha1_iperf3.yaml
