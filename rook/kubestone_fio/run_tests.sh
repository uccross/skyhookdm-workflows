#!/bin/bash
set -ex

pod=$(kubectl get pod -n kubestone -l app=fio-test -o jsonpath="{.items[0].metadata.name}")
status=$(kubectl get pod -n kubestone -l app=fio-test -o jsonpath="{.items[0].status.phase}")
while [ "$status" != "Running" ]
do
status=$(kubectl get pod -n kubestone -l app=fio-test -o jsonpath="{.items[0].status.phase}")
done

blockdevices=($BLOCKDEVICES)
for blkdev in ${blockdevices[@]}
do
kubectl exec -n kubestone $pod -- fio --name=randwrite --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=randwrite --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-randwrite.json
kubectl exec -n kubestone $pod -- fio --name=randread --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=randread --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-randread.json
kubectl exec -n kubestone $pod -- fio --name=write --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=write --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-write.json
kubectl exec -n kubestone $pod -- fio --name=read --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=read --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-read.json
done