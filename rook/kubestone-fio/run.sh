#!/bin/sh
set -ex

kubectl create -n kubestone -f ./kubestone-fio/pvc.yaml
kubectl create -n kubestone -f ./kubestone-fio/fio.yaml