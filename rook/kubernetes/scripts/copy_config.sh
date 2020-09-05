#!/bin/sh
set -eu

if [ -z "$ANSIBLE_SSH_KEY_DATA" ]; then
  echo "Expecting ANSIBLE_SSH_KEY_DATA"
  exit 1
fi

mkdir -p /root/.ssh
mkdir -p /workspace/kubeconfig
echo "$ANSIBLE_SSH_KEY_DATA" | base64 -d > /root/.ssh/id_rsa
chmod 600 /root/.ssh
chmod 400 /root/.ssh/id_rsa

HOSTS=$(cat /workspace/geni/hosts)
MASTER="$(echo "$HOSTS" | cut -d' ' -f1)"
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/etc/kubernetes/admin.conf /workspace/kubeconfig/config
