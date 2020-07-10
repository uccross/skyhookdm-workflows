#!/bin/bash
set -eu

# export the lib path
export LD_LIBRARY_PATH=/usr/lib64/ceph

# install required packages
yum -y update
yum install -y wget bc

# download the rados-store-glob.sh script
wget https://raw.githubusercontent.com/uccross/skyhookdm-ceph/skyhook-luminous/src/progly/rados-store-glob.sh > /dev/null 2>&1
chmod +x ./rados-store-glob.sh

# delete any zombie pool and create a new pool with 128 min and max PG
ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
ceph osd pool create tpchdata 128 128 replicated

# download Flatbuffer 10MB lineitem dataset
wget --no-check-certificate https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.lineitem.10MB.75Krows.obj.0 > /dev/null 2>&1
yes | PATH=$PATH:bin ./rados-store-glob.sh tpchdata  public lineitem fbx.lineitem.10MB.75Krows.obj.0

# 1% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=0$(echo "$end - $start" | bc)
fbx_1_lineitem=$result

# 10% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,71000";
end=$(date --utc "+%s.%N")
result=0$(echo "$end - $start" | bc)
fbx_10_lineitem=$result

# 100% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 1 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "*";
end=$(date --utc "+%s.%N")
result=0$(echo "$end - $start" | bc)
fbx_100_lineitem=$result

# delete the pool
ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it

result="{
    \"lineitem\": {
        \"fbx\": {
            \"1\": ${fbx_1_lineitem},
            \"10\": ${fbx_10_lineitem},
            \"100\": ${fbx_100_lineitem}
        }
    }
}"

echo "$result" > ./result
