#!/bin/bash
set -ex

POD=$(kubectl get pod -n kubestone -l app=fio-test -o jsonpath="{.items[0].metadata.name}")
blockdevices=($BLOCKDEVICES)
for blkdev in ${blockdevices[@]}
do
kubectl exec -n kubestone $POD -- fio --name=randwrite --filename=/dev/$blkdev --direct=1 --iodepth=1 --rw=randwrite --bs=4m --size=256M --output-format=json --output /tmp/fio-$blkdev-randwrite.json
kubectl exec -n kubestone $POD -- fio --name=randread --filename=/dev/$blkdev --direct=1 --iodepth=1 --rw=randread --bs=4m --size=256M --output-format=json --output /tmp/fio-$blkdev-randread.json
kubectl exec -n kubestone $POD -- fio --name=write --filename=/dev/$blkdev --direct=1 --iodepth=1 --rw=write --bs=4m --size=256M --output-format=json --output /tmp/fio-$blkdev-write.json
kubectl exec -n kubestone $POD -- fio --name=read --filename=/dev/$blkdev --direct=1 --iodepth=1 --rw=read --bs=4m --size=256M --output-format=json --output /tmp/fio-$blkdev-read.json
done