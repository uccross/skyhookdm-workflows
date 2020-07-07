#!/bin/bash
set -eu

for blkdev in ${BLOCKDEVICES[@]};
do
for io_depth in ${IO_DEPTH[@]};
do
/fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-line-$blkdev -g -r randread -r randwrite -r read -r write -t bw iops lat -d "$io_depth" -n "$NUM_JOBS"
done
/fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-3d-$blkdev -r randread -t iops -L
/fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-3d-$blkdev -r randwrite -t iops -L
/fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-3d-$blkdev -r read -t iops -L
/fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/$blkdev/$BLOCKSIZE  -T fio-3d-$blkdev -r write -t iops -L
done

plots=$(find . -maxdepth 1 -name "*.png")
for plot in ${plots[@]};
do
mv $plot ./kubestone_fio/results
done
