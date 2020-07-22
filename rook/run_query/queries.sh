#!/bin/bash
set -eu

pod=$(kubectl get pod -n "$NAMESPACE" -l app=run-query -o jsonpath="{.items[0].metadata.name}")

function k8s_exec {
  kubectl -n "$NAMESPACE" exec "$pod" -- "$@"
}

function join_by { local IFS="$1"; shift; echo "$*"; }

# download the rados-store-glob.sh script
k8s_exec curl https://raw.githubusercontent.com/uccross/skyhookdm-ceph/skyhook-luminous/src/progly/rados-store-glob.sh --output rados-store-glob.sh
k8s_exec chmod +x ./rados-store-glob.sh

# delete any zombie pool and create a new pool with 128 min and max PG
k8s_exec ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
k8s_exec ceph osd pool create tpchdata "$PG_COUNT" "$PG_COUNT" "$POOLTYPE"

# download Flatbuffer 10MB lineitem dataset
k8s_exec curl https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.lineitem.100MB.750Krows.obj.0 --output fbx.lineitem.100MB.750Krows.obj.0

for (( k=1; k<=$REPLICACY_COUNT; k++ ))
do
    k8s_exec rados -p tpchdata put public.lineitem.$k fbx.lineitem.100MB.750Krows.obj.0
done

# declare the lineitem arrays
fbx_1_lineitem=()
fbx_10_lineitem=()
fbx_100_lineitem=()

for (( k=1; k<=$QUERY_EPOCHS; k++ ))
do
# 1% selectivity
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "$REPLICACY_COUNT" --wthreads "$WTHREADS" --qdepth "$QDEPTH" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_1_lineitem+=("$result")

# 10% selectivity
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "$REPLICACY_COUNT" --wthreads "$WTHREADS" --qdepth "$QDEPTH" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,71000";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_10_lineitem+=("$result")

# 100% selectivity
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "$REPLICACY_COUNT" --wthreads "$WTHREADS" --qdepth "$QDEPTH" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "*";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_100_lineitem+=("$result")
done

# declare the lineitem arrays
fbx_1_lineitem_cls=()
fbx_10_lineitem_cls=()
fbx_100_lineitem_cls=()

for (( k=1; k<=$QUERY_EPOCHS; k++ ))
do
# 1% selectivity
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "$REPLICACY_COUNT" --use-cls --wthreads "$WTHREADS" --qdepth "$QDEPTH" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_1_lineitem_cls+=("$result")

# 10% selectivity
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "$REPLICACY_COUNT" --use-cls --wthreads "$WTHREADS" --qdepth "$QDEPTH" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,71000";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_10_lineitem_cls+=("$result")

# 100% selectivity
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "$REPLICACY_COUNT" --use-cls --wthreads "$WTHREADS" --qdepth "$QDEPTH" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "*";
end=$(date --utc "+%s.%N")
result=$(echo $end $start | awk '{print $1 - $2}')
fbx_100_lineitem_cls+=("$result")
done

# delete the pool
k8s_exec ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it

# prepare results
fbx_1_lineitem_result=$(join_by , ${fbx_1_lineitem[@]})
fbx_10_lineitem_result=$(join_by , ${fbx_10_lineitem[@]})
fbx_100_lineitem_result=$(join_by , ${fbx_100_lineitem[@]})

fbx_1_lineitem_cls_result=$(join_by , ${fbx_1_lineitem_cls[@]})
fbx_10_lineitem_cls_result=$(join_by , ${fbx_10_lineitem_cls[@]})
fbx_100_lineitem_cls_result=$(join_by , ${fbx_100_lineitem_cls[@]})

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

echo "$result" > ./run_query/results/result.json
