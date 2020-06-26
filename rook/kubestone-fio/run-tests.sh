#!/bin/sh
set -ex

POD=$(kubectl get pod -n kubestone -l app=fio-test -o jsonpath="{.items[0].metadata.name}")
kubectl exec -n kubestone $POD -- fio --name=randwrite --filename=/dev/sdb --iodepth=1 --rw=randwrite --bs=4m --size=256M --output-format=json
kubectl exec -n kubestone $POD -- fio --name=randread --filename=/dev/sdb --iodepth=1 --rw=randwrite --bs=4m --size=256M --output-format=json
kubectl exec -n kubestone $POD -- fio --name=write --filename=/dev/sdb --iodepth=1 --rw=randwrite --bs=4m --size=256M --output-format=json
kubectl exec -n kubestone $POD -- fio --name=read --filename=/dev/sdb --iodepth=1 --rw=randwrite --bs=4m --size=256M --output-format=json
