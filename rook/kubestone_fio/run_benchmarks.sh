#!/bin/bash
set -eu

function info {
  echo "[info] - $(date) - $@"
}

export PYTHONIOENCODING=UTF-8

pod=$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].metadata.name}")
while [ "$(kubectl get pod -n kubestone -l app=fio-benchmarks -o jsonpath="{.items[0].status.phase}")" != "Running" ]
do
info "waiting for pod to comeup"
sleep 5
done

targets=""
for blkdev in ${BLOCKDEVICES[@]};
do
info "formatting /dev/${blkdev}"
kubectl exec -n kubestone ${pod} -- mkfs.ext4 /dev/${blkdev}
targets+=" /dev/${blkdev} "
done

info "dropping caches"
kubectl exec -n kubestone ${pod} -- sh -c "echo 3 | tee /proc/sys/vm/drop_caches"
bench_fio_cmd="bench_fio --target ${targets} --template /fio-plot/benchmark_script/fio-job-template.fio --type device --mode read write randread randwrite --output FIO_OUTPUT -e ${IO_ENGINE} -b ${BLOCKSIZE} --iodepth ${IO_DEPTH} --numjobs ${NUM_JOBS}"

info "running benchmark"
kubectl exec -n kubestone ${pod}  -- ${bench_fio_cmd}
