#!/bin/bash
set -eu

for blkdev in ${BLOCKDEVICES[@]};
do
for io_depth in ${IO_DEPTH[@]};
do
for blksize in ${BLOCKSIZES[@]};
do
for jobsize in ${NUM_JOBS[@]};
do
fio_plot -i "./kubestone_fio/results/${blkdev}/${blksize}"  -T "fio-randread-${io_depth}-${blkdev}-${blksize}-${jobsize}"  -g -r randread  -t bw iops lat -d "$io_depth" -n "$jobsize"
fio_plot -i "./kubestone_fio/results/${blkdev}/${blksize}"  -T "fio-randwrite-${io_depth}-${blkdev}-${blksize}-${jobsize}" -g -r randwrite -t bw iops lat -d "$io_depth" -n "$jobsize"
fio_plot -i "./kubestone_fio/results/${blkdev}/${blksize}"  -T "fio-read-${io_depth}-${blkdev}-${blksize}-${jobsize}"      -g -r read      -t bw iops lat -d "$io_depth" -n "$jobsize"
fio_plot -i "./kubestone_fio/results/${blkdev}/${blksize}"  -T "fio-write-${io_depth}-${blkdev}-${blksize}-${jobsize}"     -g -r write     -t bw iops lat -d "$io_depth" -n "$jobsize"
done
done
done
done

plots=$(find . -maxdepth 1 -name "*.png")
for plot in ${plots[@]};
do
mv "$plot" ./kubestone_fio/results
done
