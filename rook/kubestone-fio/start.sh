#!/bin/bash
set -ex

kubectl create -n kubestone -f ./kubestone-fio/pv.yaml
kubectl create -n kubestone -f ./kubestone-fio/pvc.yaml
kubectl create -n kubestone -f ./kubestone-fio/job.yaml
