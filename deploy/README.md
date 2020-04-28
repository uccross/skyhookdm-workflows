# Deployment Workflows

These workflows deploy Ceph on multiple infrastructures using 
[`ceph-ansible`][ceph-ansible]. All of them generate an Ansible 
inventory and a `ceph.conf` file that can be used to obtain 
information and connect to a cluster to run subsequent orchestration 
tasks such as [running performance benchmarks](../test/cbt).

[ceph-ansible]: https://github.com/ceph/ceph-ansible
