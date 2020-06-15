#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config
kubectl delete -f ./ceph-client/deployment.yml
