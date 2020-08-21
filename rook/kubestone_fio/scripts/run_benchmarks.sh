#!/bin/bash
set -eu

export PYTHONIOENCODING=UTF-8

pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")
while [ "$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].status.phase}")" != "Running" ]
do
echo "[INFO] Waiting for pod to comeup..."
sleep 5
done

targets=""
for blkdev in ${BLOCKDEVICES[@]};
do
echo "[INFO] Formatting /dev/${blkdev}..."
kubectl exec -n kubestone "$pod" -- sh -c "mkfs.ext4 /dev/${blkdev}"
targets+=" /dev/${blkdev} "
done

echo "[INFO] Dropping system caches..."
kubectl exec -n kubestone "$pod" -- sh -c "echo 3 | tee /proc/sys/vm/drop_caches"

echo "[INFO] Running fio benchmark..."
cmd="bench_fio --target ${targets} --duration 180 --template /fio-plot/benchmark_script/fio-job-template.fio --type device --mode ${MODES} --output FIO_OUTPUT -e ${IO_ENGINE} -b ${BLOCKSIZE} --iodepth ${IO_DEPTH} --numjobs ${NUM_JOBS}"
kubectl exec -n kubestone "$pod"  -- sh -c "${cmd}"
