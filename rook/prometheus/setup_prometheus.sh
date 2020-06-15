#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
kubectl apply -f ./prometheus/service-monitor.yaml
kubectl apply -f ./prometheus/prometheus.yaml
kubectl apply -f ./prometheus/prometheus-service.yaml
echo "http://$(kubectl -n rook-ceph -o jsonpath={.status.hostIP} get pod prometheus-rook-prometheus-0):30900"
