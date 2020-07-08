#!/bin/bash
set -eu

# rados benchmarks

# remove existing pool, if any
ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# create a pool with 100 PGs
ceph osd pool create testbench 128 128

rados bench -p testbench 120 write --no-cleanup --format=json-pretty > /tmp/write.json
rados bench -p testbench 120 seq --no-cleanup --format=json-pretty > /tmp/seq.json
rados bench -p testbench 120 rand --no-cleanup --format=json-pretty > /tmp/rand.json

# clean up and delete the pool
rados -p testbench cleanup
ceph osd pool rm testbench testbench --yes-i-really-really-mean-it

# clean the rados benchmark output files
sed -i '1d' /tmp/write.json
sed -i '1d' /tmp/seq.json
sed -i '1d' /tmp/rand.json

# osd benchmarks

# count the osds
osd_count=$(ceph osd ls | wc -l)

# run the tell benchmarks
for (( i=0; i<$osd_count; i++ ))
do
   ceph tell osd.$i bench > /tmp/osd.$i.json
done