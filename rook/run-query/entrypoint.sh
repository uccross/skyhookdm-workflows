#!/bin/bash
set -ux

# export the lib path
export LD_LIBRARY_PATH=/usr/lib64/ceph

# install software
yum update
yum install -y wget bc

echo 3 | tee /proc/sys/vm/drop_caches

# download the rados-store-glob.sh script
wget https://raw.githubusercontent.com/uccross/skyhookdm-ceph/skyhook-luminous/src/progly/rados-store-glob.sh
chmod +x ./rados-store-glob.sh

######################################
###### LINEITEM - ARROW - 10MB #######
######################################
ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
ceph osd pool create tpchdata 128 128 replicated

wget --no-check-certificate https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.lineitem.10MB.75Krows.obj.0
yes | PATH=$PATH:bin ./rados-store-glob.sh tpchdata  public lineitem fbx.lineitem.10MB.75Krows.obj.0

# 100% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --use-cls --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=0$(echo "$end - $start" | bc)
echo "Lineitem - Apache Arrow - 10M - 75K Rows (100% selectivity): $result seconds"

# 100% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --use-cls --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=0$(echo "$end - $start" | bc)
echo "Lineitem - Apache Arrow - 10M - 75K Rows (100% selectivity): $result seconds"


# # 10% selectivity
# start=$(date --utc "+%s.%N")
# run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --use-cls --select "extendedprice,gt,71000" 
# end=$(date --utc "+%s.%N")
# result=0$(echo "$end - $start" | bc)
# echo "Lineitem - Apache Arrow - 10M - 75K Rows (10% selectivity): $result seconds"

# # 1% selectivity
# start=$(date --utc "+%s.%N")
# run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --use-cls --select "extendedprice,gt,91350"
# end=$(date --utc "+%s.%N")
# result=0$(echo "$end - $start" | bc)
# echo "Lineitem - Apache Arrow - 10M - 75K Rows (1% selectivity): $result seconds"

ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it


# ######################################
# ###### NCOLS100 - ARROW - 10MB #######
# ######################################
# ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
# ceph osd pool create tpchdata 128 128 replicated

# wget --no-check-certificate https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/arrow.ncols100.10MB.25Krows.obj.0 > /dev/null 2>&1
# yes | PATH=$PATH:bin ./rados-store-glob.sh tpchdata public ncols100 arrow.ncols100.10MB.25Krows.obj.0

# # 100% selectivity
# start=$(date --utc "+%s.%N")
# run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "ncols100" --use-cls  --select "*"
# end=$(date --utc "+%s.%N")
# result=0$(echo "$end - $start" | bc)
# echo "Ncols100 - Apache Arrow - 10M - 25K Rows (100% selectivity): $result seconds"

# # 10% selectivity
# start=$(date --utc "+%s.%N")
# run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "ncols100" --use-cls --select "att0,lt,1004"
# end=$(date --utc "+%s.%N")
# result=0$(echo "$end - $start" | bc)
# echo "Ncols100 - Apache Arrow - 10M - 25K Rows (10% selectivity): $result seconds"

# # 1% selectivity
# start=$(date --utc "+%s.%N")
# run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "ncols100" --use-cls --select "att0,lt,102"
# end=$(date --utc "+%s.%N")
# result=0$(echo "$end - $start" | bc)
# echo "Ncols100 - Apache Arrow - 10M - 25K Rows (1% selectivity): $result seconds"

# ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
