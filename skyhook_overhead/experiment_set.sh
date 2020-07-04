#!/bin/bash

source conf_experiment_set.config

workers_num=${workers_num[@]}
obj_sizes=${obj_sizes[@]}

echo "Experiment Set Info:"
echo "    OSD Number: $osds"
echo "    OS: $os"
echo "    Cluster SSH key path: $ssh_key"
echo "    Workers number: $workers_num"
echo "    Object sizes: $obj_sizes"
echo "    Experiment data size: $data_size MB"
echo "    Result path: $result_path"

sudo apt update
sudo apt --assume-yes install python3-pip
pip3 install runipy
# pip3 install numpy
pip3 install pandas
pip3 install matplotlib
pip3 install matplotlib

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
if [ -z workers_num ]
    then workers_num=(4)
fi
if [ -z data_size ]
    then data_size=2000
fi
if [ -z obj_sizes ]
    then obj_sizes=(10)
fi
if [ -z storage_device ]
    then storage_device="sdb"
fi
if [ -z result_path ]
    then result_path="results/"
fi

FILE=/etc/ceph
if [ ! -d "$FILE" ]; then
    bash ramdisk_ceph.sh $osds $ssh_key $os $storage_device
    bash install_skyhookdmdriver.sh
    bash prepare.sh
fi

operations=("write" "read")
rm -f output_*.csv
for obj_size in $obj_sizes
do
    echo "Object size: ${obj_size} MB"
    rm -f data
    python3 data_gen.py $data_size
    osd_last_index=$((osds-1))
    for worker_num in $workers_num
    do
        prefix="obj_${obj_sizes}_${worker_num}_"
        for operation in "${operations[@]}"
        do
            echo "Starting the experiment $operation with $worker_num workers"
            bash run_experiment.sh $worker_num $osds $operation $prefix $obj_size $result_path
        done
    done
    sleep 5
done

~/.local/bin/runipy result.ipynb
