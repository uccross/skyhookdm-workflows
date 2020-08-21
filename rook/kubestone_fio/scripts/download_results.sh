#!/bin/bash
set -eu

# download json files
mkdir -p ./kubestone_fio/results
pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")
output_files=($(kubectl exec -n kubestone "$pod" -- find FIO_OUTPUT/ -name '*.json'))
for file in ${output_files[@]}
do
kubectl cp "kubestone/${pod}:/${file}" "./kubestone_fio/results/${file}"
done

# download log files
output_files=($(kubectl exec -n kubestone "${pod}" -- find FIO_OUTPUT/ -name '*.log'))
for file in ${output_files[@]}
do
kubectl cp "kubestone/${pod}:/${file}" "./kubestone_fio/results/${file}"
done
