#!/bin/bash
set -eu

export KUBECONFIG=./kubeconfig/config
kubectl exec -n rook-ceph $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- cat /etc/ceph/keyring > ./ceph-client/config/keyring
kubectl exec -n rook-ceph $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- cat /etc/ceph/ceph.conf > ./ceph-client/config/ceph.conf
