#!/bin/bash
set -eu

export KUBECONFIG=/workspace/kubeconfig/config
kubectl apply -f ceph-client/deployment.yml
