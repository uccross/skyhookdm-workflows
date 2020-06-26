#!/bin/bash
set -ex

kubectl delete -n kubestone -f ./kubestone-fio/job.yaml
kubectl delete -n kubestone -f ./kubestone-fio/pvc.yaml
kubectl delete -n kubestone -f ./kubestone-fio/pv.yaml
