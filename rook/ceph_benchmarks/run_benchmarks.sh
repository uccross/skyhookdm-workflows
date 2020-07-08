#!/bin/bash
set -eu

# make results dir
mkdir -p ./ceph_benchmarks/results

# findout the pod
pod=$(kubectl get pod -n "$NAMESPACE" -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")

# rados benchmarks
# remove existing pool, if any
kubectl -n "$NAMESPACE" exec "$pod" -- ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# create a pool with 100 PGs
kubectl -n "$NAMESPACE" exec "$pod" -- ceph osd pool create testbench 128 128

for io_depth in ${IO_DEPTH[@]};
do
kubectl -n "$NAMESPACE" exec "$pod" -- rados bench --no-hints --concurrent-ios $io_depth -p testbench 120 write --no-cleanup --format=json-pretty > ./ceph_benchmarks/results/write-$io_depth.json
kubectl -n "$NAMESPACE" exec "$pod" -- rados bench --no-hints --concurrent-ios $io_depth -p testbench 120 seq   --no-cleanup --format=json-pretty > ./ceph_benchmarks/results/seq-$io_depth.json
kubectl -n "$NAMESPACE" exec "$pod" -- rados bench --no-hints --concurrent-ios $io_depth -p testbench 120 rand  --no-cleanup --format=json-pretty > ./ceph_benchmarks/results/rand-$io_depth.json
done

# clean up and delete the pool
kubectl -n "$NAMESPACE" exec "$pod" -- rados -p testbench cleanup
kubectl -n "$NAMESPACE" exec "$pod" -- ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# clean the rados benchmark output files
for io_depth in ${IO_DEPTH[@]};
do
sed -i '1d' ./ceph_benchmarks/results/write-$io_depth.json
sed -i '1d' ./ceph_benchmarks/results/seq-$io_depth.json
sed -i '1d' ./ceph_benchmarks/results/rand-$io_depth.json
done

# osd benchmarks
# count the osds
osd_count=$(kubectl -n "$NAMESPACE" exec "$pod" -- ceph osd ls | wc -l)

# run the tell benchmarks
for (( i=0; i<$osd_count; i++ ))
do
   kubectl -n "$NAMESPACE" exec "$pod" -- ceph tell osd.$i bench > ./ceph_benchmarks/results/osd.$i.json
done
