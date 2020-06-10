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

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.0.json /workspace/results/osd.0.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.1.json /workspace/results/osd.1.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.2.json /workspace/results/osd.2.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.3.json /workspace/results/osd.3.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.4.json /workspace/results/osd.4.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.5.json /workspace/results/osd.5.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.6.json /workspace/results/osd.6.json
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ANSIBLE_USER"@"$MASTER":/mnt/data/results/osd.7.json /workspace/results/osd.7.json
