#!/bin/bash
set -eu

blockdevices=($BLOCKDEVICES)

i=0
for blkdev in "${blockdevices[@]}"    
do
dd if=/dev/$blkdev of=here bs=1G count=1 oflag=direct 2> "/tmp/dd-${blkdev}"
i=$((i+1))
done

sleep infinity
