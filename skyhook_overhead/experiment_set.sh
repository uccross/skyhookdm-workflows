#!/bin/bash

sudo apt install python3-pip
pip3 install runipy
pip3 install numpy
pip3 install pandas
pip3 install matplotlib
pip3 install matplotlib

. conf_experiment_set.config
if [ -z osds ]
    then osds=4
fi
if [ -z os ]
    then os="ubuntu"
fi
if [ -z ssh_key ]
    then 
        echo "Error: ssh_key is not defined."
        exit 1
fi
if [ -z writers_num ]
    then writers_num=(4)
fi
if [ -z data_size ]
    then data_size=2000
fi
if [ -z obj_sizes ]
    then obj_sizes=(10)
fi

echo "Experiment Set Info:"
echo "    OSD Number: $osds"
echo "    OS: $os"
echo "    Cluster SSH key path: $ssh_key"
echo "    Writers number: $writers_num"
echo "    Object sizes: $obj_sizes"
echo "    Experiment data size: $data_size MB"

bash ramdisk_ceph.sh $osds $ssh_key $os
bash install_skyhookdmdriver.sh
bash prepare.sh

for obj_size in $obj_sizes
do
    python3 data_gen.py $data_size $obj_size

    rm -f output_*.csv
    titles="obj_size, writers, client_util, client_bandwidth"
    osd_last_index=$((osds-1))
    for osd_index in $(seq 0 $osd_last_index)
    do
        titles="$titles, OSD_${osd_index}_util"
    done

    echo "$titles" >> "output_$obj_size.csv"

    last_writers_num=$(( first_writers_num+((experiments_num-1)*step) ))
    for writer_num in $(seq $first_writers_num $step $last_writers_num)
    do
        echo "Starting the experiment with $writer_num writers"
        echo "$obj_size, $writer_num, $(bash run_experiment.sh $writer_num $osds)" >> "output_$obj_size.csv"
    done
done

~/.local/bin/runipy result.ipynb
