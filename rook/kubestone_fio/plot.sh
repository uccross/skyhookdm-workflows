#!/bin/bash
set -eu

for blkdev in ${BLOCKDEVICES[@]};
do
for io_depth in ${IO_DEPTH[@]};
do
fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-randread-$io_depth-$blkdev  -g -r randread  -t bw iops lat -d "$io_depth" -n "$NUM_JOBS"
fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-randwrite-$io_depth-$blkdev -g -r randwrite -t bw iops lat -d "$io_depth" -n "$NUM_JOBS"
fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-read-$io_depth-$blkdev      -g -r read      -t bw iops lat -d "$io_depth" -n "$NUM_JOBS"
fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-write-$io_depth-$blkdev     -g -r write     -t bw iops lat -d "$io_depth" -n "$NUM_JOBS"
done
done

plots=$(find . -maxdepth 1 -name "*.png")
for plot in ${plots[@]};
do
mv $plot ./kubestone_fio/results
done
