#!/bin/bash
set -eu

# change into kubespray dir
cd kubespray/

# install the requirements
pip install -r requirements.txt

# create a dir `skyhookcluster` from the sample dir
cp -rfp inventory/sample inventory/skyhookcluster

# specify the participating nodes IP's
HOSTS=$(cat /workspace/geni/hosts)
declare -a IPS=("$HOSTS")
CONFIG_FILE=inventory/skyhookcluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

if [ -z "$ANSIBLE_SSH_KEY_DATA" ]; then
  echo "Expecting ANSIBLE_SSH_KEY_DATA"
  exit 1
fi

mkdir -p /root/.ssh
echo "$ANSIBLE_SSH_KEY_DATA" | base64 --decode > /root/.ssh/id_rsa
chmod 600 /root/.ssh
chmod 400 /root/.ssh/id_rsa

# use ansible to deploy the cluster
ansible-playbook -i inventory/skyhookcluster/hosts.yaml --user "$ANSIBLE_USER" --become --become-user root cluster.yml
