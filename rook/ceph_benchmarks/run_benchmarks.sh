#!/bin/bash
set -eu

# rados benchmarks
ceph osd pool rm testbench testbench --yes-i-really-really-mean-it
ceph osd pool create testbench 100 100
rados bench -p testbench 120 write --no-cleanup --format=json-pretty > /tmp/write.json
rados bench -p testbench 120 seq --no-cleanup --format=json-pretty > /tmp/seq.json
rados bench -p testbench 120 rand --no-cleanup --format=json-pretty > /tmp/rand.json
rados -p testbench cleanup
ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# osd benchmarks
osd_count=$(ceph osd ls | wc -l)
for (( i=0; i<$osd_count; i++ ))
do
   ceph tell osd.$i bench > /tmp/osd.$i.json
done