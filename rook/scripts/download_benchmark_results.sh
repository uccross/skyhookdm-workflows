#!/bin/sh
set -eu

if [ -z "$ANSIBLE_SSH_KEY_DATA" ]; then
  echo "Expecting ANSIBLE_SSH_KEY_DATA"
  exit 1
fi

mkdir -p /root/.ssh
mkdir -p /workspace/results
echo "$ANSIBLE_SSH_KEY_DATA" | base64 -d > /root/.ssh/id_rsa
chmod 600 /root/.ssh
chmod 400 /root/.ssh/id_rsa

HOSTS=$(cat /workspace/geni/hosts)
MASTER="$(echo "$HOSTS" | cut -d' ' -f4)"
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/seq.json /workspace/results/seq.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/rand.json /workspace/results/rand.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/write.json /workspace/results/write.json
