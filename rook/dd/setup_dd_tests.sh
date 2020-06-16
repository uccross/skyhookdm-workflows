#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config

kubectl create -f ./dd/dd.yml

kubectl create namespace dd-tests
kubectl create serviceaccount fake-user -n dd-tests
kubectl create rolebinding fake-editor --clusterrole=edit --serviceaccount=dd-tests:fake-user -n dd-tests

kubectl create -f ./dd/deployment.yml
