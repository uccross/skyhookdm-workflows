#!/bin/bash
set -eu

export KUBECONFIG=/workspace/kubeconfig/config
kubectl exec -n rook-ceph $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- cat /etc/ceph/keyring > /workspace/ceph-client/config/keyring
kubectl exec -n rook-ceph $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- cat /etc/ceph/ceph.conf > /workspace/ceph-client/config/ceph.conf
