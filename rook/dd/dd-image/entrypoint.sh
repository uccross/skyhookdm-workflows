#!/bin/bash
set -eu

blockdevices=($BLOCKDEVICES)

i=0
for blkdev in "${blockdevices[@]}"    
do
dd if=/dev/zero of=/dev/$blkdev bs=1G count=1 oflag=direct 2> "/tmp/dd-write-${blkdev}"
dd if=/dev/$blkdev of=/dev/null bs=1G count=1 oflag=nocache 2> "/tmp/dd-read-${blkdev}"
i=$((i+1))
done

sleep infinity
