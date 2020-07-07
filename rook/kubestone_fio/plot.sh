#!/bin/bash
set -eu

for io_depth in ${IO_DEPTH[@]};
do
/fio_plot -i ./kubestone_fio/results/FIO_OUTPUT/sda2/4m  -T fio-benchmarks -g -r randread -r randwrite -r read -r write -t bw iops lat -d "$io_depth" -n "$NUM_JOBS"
done

plots=$(ls | grep "fio-benchmarks-*")
for plot in ${plots[@]};
do
mv $plot ./kubestone_fio/results
done
