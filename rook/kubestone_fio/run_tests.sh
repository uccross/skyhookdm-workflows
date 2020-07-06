#!/bin/bash
set -ex

export PYTHONIOENCODING=UTF-8

pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")
while [ "$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].status.phase}")" != "Running" ]
do
sleep 5
done

bench_fio_cmd="./bench_fio --target /dev/sda2 --type device --mode read write randread randwrite --output FIO_OUTPUT -b $BLOCKSIZE -s $SIZE --iodepth $IO_DEPTH --numjobs $NUM_JOBS"

kubectl exec -n kubestone $pod  -- $bench_fio_cmd

# blockdevices=($BLOCKDEVICES)
# for blkdev in ${blockdevices[@]}
# do
# kubectl exec -n kubestone $pod -- fio --name=randwrite --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=randwrite --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-randwrite.json
# kubectl exec -n kubestone $pod -- fio --name=randread --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=randread --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-randread.json
# kubectl exec -n kubestone $pod -- fio --name=write --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=write --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-write.json
# kubectl exec -n kubestone $pod -- fio --name=read --filename=/dev/$blkdev --direct=1 --iodepth=$IO_DEPTH --rw=read --bs=$BLOCKSIZE --size=$SIZE --ioengine=$IO_ENGINE --numjobs=$NUM_JOBS --output-format=json --output /tmp/fio-$blkdev-read.json
# done
