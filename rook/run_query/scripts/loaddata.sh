#!/bin/bash
set -eu

pod=$(kubectl get pod -n "$NAMESPACE" -l app=run-query -o jsonpath="{.items[0].metadata.name}")
function k8s_exec {
  kubectl -n "$NAMESPACE" exec "$pod" -- "$@"
}

# delete any zombie pool and create a new pool
echo "[INFO] Delete existing pool and create a new pool..."
k8s_exec ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
k8s_exec ceph osd pool create tpchdata "$PG_COUNT" "$PG_COUNT" "$POOLTYPE"

# set pool size to 1 to disable replicacy
echo "[INFO] Disable replicacy on pool..."
k8s_exec ceph osd pool set tpchdata size 1

# download flatbuffer 10MB lineitem dataset
echo "[INFO] Download dataset..."
k8s_exec curl https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.lineitem.10MB.75Krows.obj.0 --output fbx.lineitem.10MB.75Krows.obj.0

# put the data into objects in a loop using all the cores
echo "[INFO] Copying put script to pod..."
kubectl cp ./run_query/scripts/put.py "${NAMESPACE}/${pod}:/tmp"

echo "[INFO] Launching multithreaded put..."
k8s_exec python3 /tmp/put.py --count "$OBJECT_COUNT"
