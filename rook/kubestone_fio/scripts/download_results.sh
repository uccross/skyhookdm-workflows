#!/bin/bash
set -eu

pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")

echo "[INFO] Packing result files..."
kubectl exec -n kubestone "$pod" -- sh -c "rm -rf results.tar.gz"
kubectl exec -n kubestone "$pod" -- sh -c "tar -zcvf results.tar.gz FIO_OUTPUT/"

echo "[INFO] Downloading results archive..."
kubectl cp "kubestone/${pod}:/results.tar.gz" "./kubestone_fio/results.tar.gz"

echo "[INFO] Unpacking results archive..."
tar -xvzf ./kubestone_fio/results.tar.gz -C ./kubestone_fio
mv ./kubestone_fio/FIO_OUTPUT ./kubestone_fio/results
