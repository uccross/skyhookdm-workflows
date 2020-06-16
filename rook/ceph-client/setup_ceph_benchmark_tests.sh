#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config

cp ./ceph-client/client-pod.yml ./ceph-client/client-pod.temp.yml
sed -i "s/__docker_username__/$DOCKER_USERNAME/g" ./ceph-client/client-pod.temp.yml
kubectl apply -f ./ceph-client/client-pod.temp.yml
rm ./ceph-client/client-pod.temp.yml
