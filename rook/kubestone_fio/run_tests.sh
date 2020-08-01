#!/bin/bash
set -eu

export PYTHONIOENCODING=UTF-8

pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")
while [ "$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].status.phase}")" != "Running" ]
do
echo "waiting for pod to comeup"
sleep 5
done

targets=""
for blkdev in ${BLOCKDEVICES[@]};
do
# format the partition
kubectl exec -n kubestone "$pod" -- mkfs.ext4 /dev/$blkdev
targets+=" /dev/$blkdev "
done

kubectl exec -n kubestone "$pod" -- sh -c "echo 3 | tee /proc/sys/vm/drop_caches"

bench_fio_cmd="bench_fio --target ${targets} --template /fio-plot/benchmark_script/fio-job-template.fio --type device --mode read write randread randwrite --output FIO_OUTPUT -e ${IO_ENGINE} -b ${BLOCKSIZE} -s ${SIZE} --iodepth ${IO_DEPTH} --numjobs ${NUM_JOBS}"
# run the benchmark
kubectl exec -n kubestone "$pod"  -- ${bench_fio_cmd}
