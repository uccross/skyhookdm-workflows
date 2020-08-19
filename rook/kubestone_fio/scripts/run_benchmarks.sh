#!/bin/bash
set -eu

function info {
  echo "[info] - $(date +%r) - $*"
}

export PYTHONIOENCODING=UTF-8

info "Finding pod..."
pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")

while [ "$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].status.phase}")" != "Running" ]
do
info "Waiting for pod to comeup..."
sleep 5
done

targets=""
for blkdev in ${BLOCKDEVICES[@]};
do
info "Formatting /dev/${blkdev}..."
kubectl exec -n kubestone "$pod" -- mkfs.ext4 "/dev/${blkdev}"
targets+=" /dev/${blkdev} "
done

info "Dropping caches..."
kubectl exec -n kubestone "$pod" -- sh -c "echo 3 | tee /proc/sys/vm/drop_caches"

info "Running benchmark..."
bench_fio_cmd="bench_fio --target ${targets} --template /fio-plot/benchmark_script/fio-job-template.fio --type device --mode ${MODES} --output FIO_OUTPUT -e ${IO_ENGINE} -b ${BLOCKSIZE} --iodepth ${IO_DEPTH} --numjobs ${NUM_JOBS}"
kubectl exec -n kubestone "$pod" -- sh -c "$bench_fio_cmd"
