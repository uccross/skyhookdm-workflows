#!/bin/bash
set -eu

export KUBECONFIG=/workspace/kubeconfig/config
kubectl delete -f ceph-client/deployment.yml
