#!/bin/bash
set -eu

blockdevices=($(lsblk -d -io NAME | grep -v NAME))
hostname=$(hostname)

for blkdev in "${blockdevices[@]}"    
do
dd if=/dev/$blkdev of=here bs=1G count=1 oflag=direct 2> /tmp/dd-$blkdev-$hostname.txt
done

sleep infinity
