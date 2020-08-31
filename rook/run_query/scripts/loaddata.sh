#!/bin/bash
set -eu

pod=$(kubectl get pod -n "$NAMESPACE" -l app=run-query -o jsonpath="{.items[0].metadata.name}")
function k8s_exec {
  kubectl -n "$NAMESPACE" exec "$pod" -- "$@"
}

# download the rados-store-glob.sh script
k8s_exec curl https://raw.githubusercontent.com/uccross/skyhookdm-ceph/skyhook-luminous/src/progly/rados-store-glob.sh --output rados-store-glob.sh
k8s_exec chmod +x ./rados-store-glob.sh

# delete any zombie pool and create a new pool
k8s_exec ceph osd pool delete tpchdata tpchdata --yes-i-really-really-mean-it
k8s_exec ceph osd pool create tpchdata "$PG_COUNT" "$PG_COUNT" "$POOLTYPE"

# set pool size to 1 to disable replicacy
k8s_exec ceph osd pool set tpchdata size 1

# download flatbuffer 10MB lineitem dataset
k8s_exec curl https://users.soe.ucsc.edu/~jlefevre/skyhookdb/testdata/pdsw19/sampledata/fbx.lineitem.10MB.75Krows.obj.0 --output fbx.lineitem.10MB.75Krows.obj.0

# put the data in a loop
for (( k=1; k<=REPLICACY_COUNT; k++ ))
do
    k8s_exec rados -p tpchdata put public.lineitem."$k" fbx.lineitem.10MB.75Krows.obj.0
done