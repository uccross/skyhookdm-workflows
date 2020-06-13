#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config
kubectl apply -f ./ceph-client/deployment.yml
