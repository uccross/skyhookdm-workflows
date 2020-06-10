#!/bin/bash
set -eux

# run the benchmarks here
sleep 2

# rados benchmarks
ceph osd pool create testbench 100 100
rados bench -p testbench 120 write --no-cleanup --format=json-pretty > /workspace/write.json
rados bench -p testbench 120 seq --no-cleanup --format=json-pretty > /workspace/seq.json
rados bench -p testbench 120 rand --no-cleanup --format=json-pretty > /workspace/rand.json
rados -p testbench cleanup
ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# osd benchmarks
osd_count=$(ceph osd ls | wc -l)
for (( i=0; i<$osd_count; i++ ))
do
   ceph tell osd.$i bench > /workspace/osd.$i.json
done
