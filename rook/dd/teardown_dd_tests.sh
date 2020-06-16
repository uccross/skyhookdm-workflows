#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config

kubectl delete -f ./dd/deployment.yml

kubectl delete rolebinding -n dd-tests fake-editor
kubectl delete serviceaccount -n dd-tests fake-user
kubectl delete namespace dd-tests

kubectl delete -f ./dd/dd.yml
