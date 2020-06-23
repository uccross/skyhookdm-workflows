#!/bin/bash

sudo apt install python3-pip
pip3 install runipy
pip3 install numpy
pip3 install pandas
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
if [ -z first_writers_num ]
    then first_writers_num=4
fi
if [ -z data_size ]
    then data_size=2000
fi
if [ -z experiments_num ]
    then experiments_num=8
fi
if [ -z step ]
    then step=4
fi

echo "Experiment Set Info:"
echo "    OSD Number: $osds"
echo "    OS: $os"
echo "    Cluster SSH key path: $ssh_key"
echo "    Writers number for the first Experiment: $first_writers_num"
echo "    Writers number increment step: $step"
echo "    Experiment data size: $data_size MB"
echo "    Number of Experiments: $experiments_num"

bash ramdisk_ceph.sh $osds $ssh_key $os
bash install_skyhookdmdriver.sh
bash prepare.sh
python3 data_gen.py $data_size

rm -f output.csv
titles="writers, client_util, client_bandwidth"
osd_last_index=$((osds-1))
for osd_index in $(seq 0 $osd_last_index)
do
    titles="$titles, OSD_${osd_index}_util"
done

echo "$titles" >> output.csv

last_writers_num=$(( first_writers_num+((experiments_num-1)*step) ))
for writer_num in $(seq $first_writers_num $step $last_writers_num)
do
    echo "Starting the experiment with $writer_num writers"
    echo "$writer_num, $(bash run_experiment.sh $writer_num $osds)" >> output.csv
done

~/.local/bin/runipy result.ipynb

