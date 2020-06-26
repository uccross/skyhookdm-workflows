#!/bin/bash
set -ex

mkdir -p ./kubestone-fio/results
POD=$(kubectl get pod -n kubestone -l app=fio-test -o jsonpath="{.items[0].metadata.name}")
output_files=($(kubectl exec -n kubestone "$POD" -- ls /tmp | grep 'fio-*'))
for file in ${output_files[@]}
do
kubectl cp kubestone/$POD:/tmp/$file ./kubestone-fio/results/$file
done