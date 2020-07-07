#!/bin/bash
set -eu

export PYTHONIOENCODING=UTF-8

pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")
while [ "$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].status.phase}")" != "Running" ]
do
sleep 5
done

targets=""
for blkdev in ${BLOCKDEVICES[@]};
do
targets+=" /dev/$blkdev "
done

bench_fio_cmd="./bench_fio --target ${targets} --type device --mode read write randread randwrite --output FIO_OUTPUT -b $BLOCKSIZE -s $SIZE --iodepth $IO_DEPTH --numjobs $NUM_JOBS"

kubectl exec -n kubestone $pod  -- $bench_fio_cmd
