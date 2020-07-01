#!/bin/bash
set -ex

mkdir -p ./kubestone_fio/results
pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")
output_files=($(kubectl exec -n kubestone "$pod" -- ls /tmp | grep 'fio-*'))
for file in ${output_files[@]}
do
kubectl cp kubestone/$pod:/tmp/$file ./kubestone_fio/results/$file
done