#!/bin/bash
set -eu

mkdir -p ./radosbench/results
pod=$(kubectl get pod -n ${NAMESPACE} -l app=ceph-benchmarks -o jsonpath="{.items[0].metadata.name}")

function k8s_exec {
  kubectl -n ${NAMESPACE} exec ${pod} -- "$@"
}

function info {
  echo "[info] - $(date) - $@"
}

info "removing existing pools, if any"
k8s_exec ceph osd pool rm ${POOL_NAME} ${POOL_NAME} --yes-i-really-really-mean-it

info "creating new pool"
k8s_exec ceph osd pool create ${POOL_NAME} ${PG_SIZE} ${PG_SIZE} ${POOL_TYPE}

if [[ "${REPLICATION_DISABLED}" -eq "1" ]]; then
info "disabling replication in the pool"
k8s_exec ceph osd pool set ${POOL_NAME} size 1
fi

for t in ${THREADS[@]};
do
info "running write bench with $t thread"
k8s_exec rados bench --no-hints -b ${OBJECT_SIZE} -t ${t} -p ${POOL_NAME} ${WRITE_DURATION} write --no-cleanup --format=json-pretty > ./radosbench/results/write-${t}.json

info "running seq bench with $t thread"
k8s_exec rados bench --no-hints                   -t ${t} -p ${POOL_NAME} ${READ_DURATION} seq   --no-cleanup --format=json-pretty > ./radosbench/results/seq-${t}.json

info "running rand bench with $t thread"
k8s_exec rados bench --no-hints                   -t ${t} -p ${POOL_NAME} ${READ_DURATION} rand  --no-cleanup --format=json-pretty > ./radosbench/results/rand-${t}.json
done

info "cleaning up and removing pool"
k8s_exec rados -p ${POOL_NAME} cleanup
k8s_exec ceph osd pool rm ${POOL_NAME} ${POOL_NAME} --yes-i-really-really-mean-it

info "writing out results"
for t in ${THREADS[@]};
do
sed -i '1d' ./radosbench/results/write-${t}.json
sed -i '1d' ./radosbench/results/seq-${t}.json
sed -i '1d' ./radosbench/results/rand-${t}.json
done

info "counting OSDs"
osd_count=$(kubectl -n ${NAMESPACE} exec ${pod} -- ceph osd ls | wc -l)

for (( i=0; i<$osd_count; i++ ))
do
info "ceph tell osd.$i bench"
k8s_exec ceph tell osd.$i bench > ./radosbench/results/osd.$i.json
done
