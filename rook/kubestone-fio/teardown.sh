#!/bin/sh
set -ex

kubectl delete -n kubestone -f ./kubestone-fio/job.yaml
# kubectl delete -n kubestone -f ./kubestone-fio/pv.yaml
# kubectl delete -n kubestone -f ./kubestone-fio/pvc.yaml
