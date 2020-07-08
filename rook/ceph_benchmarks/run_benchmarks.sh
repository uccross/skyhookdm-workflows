#!/bin/bash
set -eu

# rados benchmarks
# remove existing pool, if any
ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# create a pool with 100 PGs
ceph osd pool create testbench 128 128

for io_depth in ${IO_DEPTH{@}};
do
rados bench --no-hints --concurrent-ios $io_depth -p testbench 120 write --no-cleanup --format=json-pretty > /tmp/write-$io_depth.json
rados bench --no-hints --concurrent-ios $io_depth -p testbench 120 seq   --no-cleanup --format=json-pretty > /tmp/seq-$io_depth.json
rados bench --no-hints --concurrent-ios $io_depth -p testbench 120 rand  --no-cleanup --format=json-pretty > /tmp/rand-$io_depth.json
done

# clean up and delete the pool
rados -p testbench cleanup
ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# clean the rados benchmark output files
for io_depth in ${IO_DEPTH{@}};
do
sed -i '1d' /tmp/write-$io_depth.json
sed -i '1d' /tmp/seq-$io_depth.json
sed -i '1d' /tmp/rand-$io_depth.json
done

# osd benchmarks
# count the osds
osd_count=$(ceph osd ls | wc -l)

# run the tell benchmarks
for (( i=0; i<$osd_count; i++ ))
do
   ceph tell osd.$i bench > /tmp/osd.$i.json
done
