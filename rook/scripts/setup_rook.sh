#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config
kubectl apply -f ./rook/common.yaml
kubectl apply -f ./rook/operator.yaml
kubectl apply -f ./rook/cluster.yaml
kubectl apply -f ./rook/toolbox.yaml
