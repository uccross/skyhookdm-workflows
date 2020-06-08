#!/bin/bash
set -eux

# run the benchmarks here
sleep 15
ceph osd pool create testbench 100 100
rados bench -p testbench 10 write --no-cleanup --format=json-pretty > /workspace/write.json
rados bench -p testbench 10 seq --no-cleanup --format=json-pretty > /workspace/seq.json
rados bench -p testbench 10 rand --no-cleanup --format=json-pretty > /workspace/rand.json
