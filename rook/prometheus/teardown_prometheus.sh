#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config
kubectl delete -f ./prometheus/service-monitor.yaml
kubectl delete -f ./prometheus/prometheus.yaml
kubectl delete -f ./prometheus/prometheus-service.yaml
kubectl delete -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
