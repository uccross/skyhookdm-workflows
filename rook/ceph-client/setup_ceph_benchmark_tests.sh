#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config

cp ./ceph-client/deployment.yml ./ceph-client/deployment.temp.yml
sed -i "s/__docker_username__/$DOCKER_USERNAME/g" ./ceph-client/deployment.temp.yml
kubectl apply -f ./ceph-client/deployment.temp.yml
rm ./ceph-client/deployment.temp.yml
