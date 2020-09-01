#!/bin/bash
set -eu

pod=$(kubectl get pod -n "${NAMESPACE}" -l app=run-query -o jsonpath="{.items[0].metadata.name}")

function k8s_exec {
  kubectl -n "${NAMESPACE}" exec "${pod}" -- "$@"
}

function join_by { local IFS="$1"; shift; echo "$*"; }

function clear_caches_on_osds {
  osd_pods=($(kubectl get pods --selector app=rook-ceph-osd -n rook-ceph  -o jsonpath='{.items[*].metadata.name}'))
  for osd_pod in ${osd_pods[@]};
  do
    echo "[INFO] Clearing cache on OSD ${osd_pod}"
    kubectl -n rook-ceph exec "$osd_pod" -- sh -c "sync"
    kubectl -n rook-ceph exec "$osd_pod" -- sh -c "echo 3 | sudo tee /proc/sys/vm/drop_caches"
    kubectl -n rook-ceph exec "$osd_pod" -- sh -c "sync"
  done

  echo "[INFO] Clearing cache on client pod"
  kubectl -n "$NAMESPACE" exec "$pod" -- sh -c "sync"
  kubectl -n "$NAMESPACE" exec "$pod" -- sh -c "echo 3 | sudo tee /proc/sys/vm/drop_caches"
  kubectl -n "$NAMESPACE" exec "$pod" -- sh -c "sync"

  sleep 2
}

# declare the lineitem arrays
fbx_1_lineitem=()
fbx_10_lineitem=()
fbx_100_lineitem=()

for (( k=1; k<=QUERY_EPOCHS; k++ ))
do
# 1% selectivity
clear_caches_on_osds
echo "[INFO] Client side 1%"
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "${OBJECT_COUNT}" --wthreads "${WTHREADS}" --qdepth "${QDEPTH}" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=$(echo "${end}" "${start}" | awk '{print $1 - $2}')
fbx_1_lineitem+=("$result")

# 10% selectivity
clear_caches_on_osds
echo "[INFO] Client side 10%"
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "${OBJECT_COUNT}" --wthreads "${WTHREADS}" --qdepth "${QDEPTH}" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,71000";
end=$(date --utc "+%s.%N")
result=$(echo "${end}" "${start}" | awk '{print $1 - $2}')
fbx_10_lineitem+=("$result")

# 100% selectivity
clear_caches_on_osds
echo "[INFO] Client side 100%"
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "${OBJECT_COUNT}" --wthreads "${WTHREADS}" --qdepth "${QDEPTH}" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "*";
end=$(date --utc "+%s.%N")
result=$(echo "${end}" "${start}" | awk '{print $1 - $2}')
fbx_100_lineitem+=("${result}")
done

# declare the lineitem arrays
fbx_1_lineitem_cls=()
fbx_10_lineitem_cls=()
fbx_100_lineitem_cls=()

for (( k=1; k<=QUERY_EPOCHS; k++ ))
do
# 1% selectivity
clear_caches_on_osds
echo "[INFO] Storage side 1%"
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "${OBJECT_COUNT}" --use-cls --wthreads "${WTHREADS}" --qdepth "${QDEPTH}" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,91350";
end=$(date --utc "+%s.%N")
result=$(echo "${end}" "${start}" | awk '{print $1 - $2}')
fbx_1_lineitem_cls+=("${result}")

# 10% selectivity
clear_caches_on_osds
echo "[INFO] Storage side 10%"
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "${OBJECT_COUNT}" --use-cls --wthreads "${WTHREADS}" --qdepth "${QDEPTH}" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "extendedprice,gt,71000";
end=$(date --utc "+%s.%N")
result=$(echo "${end}" "${start}" | awk '{print $1 - $2}')
fbx_10_lineitem_cls+=("${result}")

# 100% selectivity
clear_caches_on_osds
echo "[INFO] Storage side 100%"
start=$(date --utc "+%s.%N")
k8s_exec run-query --num-objs "${OBJECT_COUNT}" --use-cls --wthreads "${WTHREADS}" --qdepth "${QDEPTH}" --pool tpchdata --oid-prefix "public" --table-name "lineitem" --quiet --select "*";
end=$(date --utc "+%s.%N")
result=$(echo "${end}" "${start}" | awk '{print $1 - $2}')
fbx_100_lineitem_cls+=("${result}")
done

# prepare results
fbx_1_lineitem_result=$(join_by , "${fbx_1_lineitem[@]}")
fbx_10_lineitem_result=$(join_by , "${fbx_10_lineitem[@]}")
fbx_100_lineitem_result=$(join_by , "${fbx_100_lineitem[@]}")

fbx_1_lineitem_cls_result=$(join_by , "${fbx_1_lineitem_cls[@]}")
fbx_10_lineitem_cls_result=$(join_by , "${fbx_10_lineitem_cls[@]}")
fbx_100_lineitem_cls_result=$(join_by , "${fbx_100_lineitem_cls[@]}")

mkdir -p ./run_query/results

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
