#!/bin/bash
set -eux

# export the lib path
export LD_LIBRARY_PATH=/usr/lib64/ceph

# download the rados-store-glob.sh script
wget https://raw.githubusercontent.com/uccross/skyhookdm-ceph/skyhook-luminous/src/progly/rados-store-glob.sh
chmod +x ./rados-store-glob.sh

# create the pool
ceph osd pool create tpchdata 128 128 replicated

# test with lineintem 10MB dataset
wget --no-check-certificate https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.lineitem.10MB.75Krows.obj.0
yes | PATH=$PATH:bin ./rados-store-glob.sh tpchdata  public  lineitem fbx.lineitem.10MB.75Krows.obj.0

# 100% selectivity
start=$(date +%s)
run-query --num-objs 2 --pool tpchdata --oid-prefix "public" --table-name "lineitem"  --select "*" > /dev/null 2>&1
end=$(date +%s)
result=$(( $end - $start ))
echo "Lineitem - 10M - 75K Rows (100% selectivity): $result seconds"

# 10% selectivity
start=$(date +%s)
run-query --num-objs 2 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --select "extendedprice,gt,71000" > /dev/null 2>&1
end=$(date +%s)
result=$(( $end - $start ))
echo "Lineitem - 10M - 75K Rows (10% selectivity): $result seconds"

# 1% selectivity
start=$(date +%s)
run-query --num-objs 2 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --select "extendedprice,gt,91350" > /dev/null 2>&1
end=$(date +%s)
result=$(( $end - $start ))
echo "Lineitem - 10M - 75K Rows (1% selectivity): $result seconds"

# delete the pool
ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it

# create the pool
ceph osd pool create tpchdata 128 128 replicated

# test with ncols100 10MB dataset
wget --no-check-certificate wget --no-check-certificate https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.ncols100.10MB.25Krows.obj.0
yes | PATH=$PATH:bin ./rados-store-glob.sh tpchdata  public  lineitem fbx.ncols100.10MB.25Krows.obj.0

# 100% selectivity
start=$(date +%s)
run-query --num-objs 2 --pool tpchdata --oid-prefix "public" --table-name "ncols100"  --select "*" > /dev/null 2>&1
end=$(date +%s)
result=$(( $end - $start ))
echo "Ncols100 - 10M - 75K Rows (100% selectivity): $result seconds"

# 10% selectivity
start=$(date +%s)
run-query --num-objs 2 --pool tpchdata --oid-prefix "public" --table-name "ncols100" --select "att0,lt,1004" > /dev/null 2>&1
end=$(date +%s)
result=$(( $end - $start ))
echo "Ncols100 - 10M - 75K Rows (10% selectivity): $result seconds"

# 1% selectivity
start=$(date +%s)
run-query --num-objs 2 --pool tpchdata --oid-prefix "public" --table-name "ncols100" --select "att0,lt,102" > /dev/null 2>&1
end=$(date +%s)
result=$(( $end - $start ))
echo "Ncols100 - 10M - 75K Rows (1% selectivity): $result seconds"

# delete the pool
ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
