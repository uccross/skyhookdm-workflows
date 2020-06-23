#!/bin/bash
set -ex

export KUBECONFIG=./kubeconfig/config

# start the iperf benchmark pods 
kubectl create -n kubestone -f ./kubestone-iperf/iperf.yaml
