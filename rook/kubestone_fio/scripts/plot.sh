#!/bin/bash
set -eu

for blkdev in ${BLOCKDEVICES[@]};
do
for io_depth in ${IO_DEPTH[@]};
do
for mode in ${MODES[@]};
do
fio_plot -i "./kubestone_fio/results/FIO_OUTPUT/${blkdev}/${BLOCKSIZE}" -T "fio-${mode}-${io_depth}-${blkdev}" -g --rw "$mode" -t bw iops lat -d "$io_depth" -n "$NUM_JOBS"
done
done
done

plots=$(find . -maxdepth 1 -name "*.png")
for plot in ${plots[@]};
do
mv "$plot" ./kubestone_fio/results
done
