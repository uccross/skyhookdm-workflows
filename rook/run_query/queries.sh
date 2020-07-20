#!/bin/bash
set -eux

# export the lib path
export LD_LIBRARY_PATH=/usr/lib64/ceph

# download the rados-store-glob.sh script
curl https://raw.githubusercontent.com/uccross/skyhookdm-ceph/skyhook-luminous/src/progly/rados-store-glob.sh --output rados-store-glob.sh > /dev/null 2>&1
chmod +x ./rados-store-glob.sh

# delete any zombie pool and create a new pool with 128 min and max PG
ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
ceph osd pool create tpchdata 128 128 "$POOLTYPE"

# download Flatbuffer 10MB lineitem dataset
curl https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.lineitem.100MB.750Krows.obj.0 --output fbx.lineitem.100MB.750Krows.obj.0 > /dev/null 2>&1
# yes | PATH=$PATH:bin ./rados-store-glob.sh tpchdata  public lineitem fbx.lineitem.100MB.750Krows.obj.0

for i in {0..19}
do
    rados -p tpchdata put public.lineitem.$i fbx.lineitem.100MB.750Krows.obj.0
done

# declare the lineitem arrays
fbx_1_lineitem=()
fbx_10_lineitem=()
fbx_100_lineitem=()

for j in {0..9}
do
# 1% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 20 --wthreads 14 --qdepth 56 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_1_lineitem+=("$result")

# 10% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 20 --wthreads 14 --qdepth 56 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,71000";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_10_lineitem+=("$result")

# 100% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 20 --wthreads 14 --qdepth 56 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "*";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_100_lineitem+=("$result")
done

sum=0
for i in ${fbx_1_lineitem[@]}
do
  sum=$(echo $sum $i | awk '{print $1 + $2}')
done
fbx_1_lineitem_result=$(echo "$sum" 10 | awk '{print $1/$2}')

sum=0
for i in ${fbx_10_lineitem[@]}
do
  sum=$(echo $sum $i | awk '{print $1 + $2}')
done
fbx_10_lineitem_result=$(echo "$sum" 10 | awk '{print $1/$2}')

sum=0
for i in ${fbx_100_lineitem[@]}
do
  sum=$(echo $sum $i | awk '{print $1 + $2}')
done
fbx_100_lineitem_result=$(echo "$sum" 10 | awk '{print $1/$2}')

# declare the lineitem arrays
fbx_1_lineitem_cls=()
fbx_10_lineitem_cls=()
fbx_100_lineitem_cls=()

for j in {0..9}
do
# 1% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 20 --use-cls --wthreads 14 --qdepth 56 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_1_lineitem_cls+=("$result")

# 10% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 20 --use-cls --wthreads 14 --qdepth 56 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,71000";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_10_lineitem_cls+=("$result")

# 100% selectivity
start=$(date --utc "+%s.%N")
run-query --num-objs 20 --use-cls --wthreads 14 --qdepth 56 --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "*";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_100_lineitem_cls+=("$result")
done

sum=0
for i in ${fbx_1_lineitem_cls[@]}
do
  sum=$(echo $sum $i | awk '{print $1 + $2}')
done
fbx_1_lineitem_cls_result=$(echo "$sum" 10 | awk '{print $1/$2}')

sum=0
for i in ${fbx_10_lineitem_cls[@]}
do
  sum=$(echo $sum $i | awk '{print $1 + $2}')
done
fbx_10_lineitem_cls_result=$(echo "$sum" 10 | awk '{print $1/$2}')

sum=0
for i in ${fbx_100_lineitem_cls[@]}
do
  sum=$(echo $sum $i | awk '{print $1 + $2}')
done
fbx_100_lineitem_cls_result=$(echo "$sum" 10 | awk '{print $1/$2}')

# delete the pool
ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it

result="{
    \"lineitem\": {
        \"fbx\": {
            \"1\": \"${fbx_1_lineitem_result}\",
            \"10\": \"${fbx_10_lineitem_result}\",
            \"100\": \"${fbx_100_lineitem_result}\"
        },
        \"fbx_cls\": {
            \"1\": \"${fbx_1_lineitem_cls_result}\",
            \"10\": \"${fbx_10_lineitem_cls_result}\",
            \"100\": \"${fbx_100_lineitem_cls_result}\"
        }
    }
}"

echo "$result" > ./result.json
