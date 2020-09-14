# SkyhookDM-Benchmarks Workflow

A set of [Popper](https://getpopper.io) workflows to automate large-scale tests and benchmarks of SkyhookDM-Ceph in a Kubernetes cluster.
Below given is an exhaustive guide on how to use the workflows to automate Ceph experiments.

## Cloning the project

```bash
$ git clone --recursive https://github.com/uccross/skyhookdm-workflows
```

## Installing Popper
```bash
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install popper
```
> To install Popper with Docker, check [this](https://github.com/getpopper/popper#installation) out.

## Booting up a Kubernetes cluster in Cloudlab

```bash
# generate the .env file and populate it
$ cp .env.example .env 

# apply the environment variables to your shell
$ source .env

# boot up nodes in cloudlab
$ popper run -f workflows/nodes.yml setup

# deploy kubernetes and download the kube config
$ popper run -f workflows/kubernetes.yml setup
$ popper run -f workflows/kubernetes.yml copy-kube-config

# teardown kubernetes + nodes
$ popper run -f workflows/nodes.yml teardown
```

> You can also use the workflow given [here](https://github.com/getpopper/kubernetes-cluster-setup-workflow).

## Setting up Vanilla Ceph cluster

```bash
# setup
$ popper run -f workflows/rook.yml setup-ceph

# download the ceph config
$ popper run -f workflows/rook.yml download-config

# teardown
$ popper run -f workflows/rook.yml teardown-ceph
```

To change the vanilla Ceph cluster into a SkyhookDM cluster, run the `setup-skyhook-ceph` step from the [`workflows/rook.yml`](https://github.com/uccross/skyhookdm-workflows/blob/master/rook/workflows/rook.yml) workflow.
This will update the Ceph config to load the tabular libraries and will update and restart all the daemons to use the [uccross/skyhookdm-ceph:v14.2.9](https://hub.docker.com/layers/uccross/skyhookdm-ceph/v14.2.9/images/sha256-05ad184557c2cfeed8b2caf048db2c1748dd38e9c322b2d3178bb6380e30509b?context=explore) image which is maintained here.

In general, if you need to upgrade the Ceph image in your Rook cluster using Popper, update the `{"spec": {"cephVersion": {"image": "myrepo/mycephimage"}}}` in the [`rook/cluster_ceph.yaml`](https://github.com/uccross/skyhookdm-workflows/blob/master/rook/rook/cluster_ceph.yaml) file and run the `setup-ceph` step.
The upgrade process is described in more detail [here](https://github.com/rook/rook/blob/master/Documentation/ceph-upgrade.md#ceph-version-upgrades).

## Setting up SkyhookDM Ceph cluster using Rook

```bash
# setup
$ popper run -f workflows/rook.yml setup-skyhook-ceph

# download the ceph config
$ popper run -f workflows/rook.yml download-config

# teardown
$ popper run -f workflows/rook.yml teardown-skyhook-ceph
```
> The workflow given [here](https://github.com/uccross/skyhookdm-ceph-cls/blob/master/.popper.yml) can be run to build SkyhookDM and to build and push the SkyhookDM Docker image for use with Rook.


## Setting up Prometheus Monitoring with Grafana Dashboard
```bash
# setup monitoring
$ popper run -f workflows/prometheus.yml setup

# teardown monitoring
$ popper run -f workflows/prometheus.yml teardown
```

<img src="https://user-images.githubusercontent.com/33978990/92876578-e91b3e00-f427-11ea-8c0c-8b7887f9168b.png" height="250" width="550" />

## Performing Rados and OSD benchmarks
```bash
$ popper run -f workflows/radosbench.yml -s _CLIENT=<client-hostname>
```

The rados benchmark workflow plots the latency and bandwidth of the rados object store at varying IO depths over a period of 120 seconds for write, read and sequential workloads. Example rados benchmark plots are shown below.

Each of the OSD's are also benchmarked using the native ceph osd benchmark tool, `ceph tell`. 
Both bandwidth (throughput) and IOPS is measured. A set of example OSD benchmark plots are shown below.


<img src="https://user-images.githubusercontent.com/33978990/92874999-2e3e7080-f426-11ea-8d78-7e82f841cf9b.png" height="300" width="450" />

<img src="https://user-images.githubusercontent.com/33978990/92875116-5332e380-f426-11ea-862b-237f20194506.png" height="300" width="450" />

## Running Query benchmarks
```bash
$ popper run -f workflows/run_query.yml -s _CLIENT=<client-hostname>
```

These workflows run queries over tpch dataset at 1%, 10%, 100% selectivity in arrow (currently not supported) and flatbuffer format and plots the run time of the queries against selectivity. An example plot is shown below.

<img src="https://user-images.githubusercontent.com/33978990/92876259-832eb680-f427-11ea-947e-e0b94ebc3100.png" height="300" width="450" />

## Kubestone benchmarks

The `fio` and `iperf` benchmarks require [`kubestone`](https://kubestone.io/en/latest/) to be installed and a `kubestone` namespace to be created in the cluster.
Please follow the instructions given [here](https://kubestone.io/en/latest/quickstart/#installation) to install kubestone in the cluster. The namespace can be created by doing [this](https://kubestone.io/en/latest/quickstart/#namespace) or you can just do the following,

```bash
# clone the `kubestone` repo
$ git clone https://github.com/xridge/kubestone

# build the definition and create
$ cd kubestone/config/default
$ kustomize build | kubectl create -f -

# create the `kubestone` namespace
$ kubectl create namespace kubestone
```

### `iperf`
```bash
# between server and client-1
$ popper run -f workflows/iperf.yml -s _SERVER=<server-hostname> -s _CLIENT=<client-one-hostname>

# between server and client-2
$ popper run -f workflows/iperf.yml -s _SERVER=<server-hostname> -s _CLIENT=<client-two-hostname>

# between server and client-3
$ popper run -f workflows/iperf.yml -s _SERVER=<server-hostname> -s _CLIENT=<client-three-hostname>
.
.
```

The value to be provided to the `SERVER` and `CLIENT` substitution variables of the `popper run` command is the hostname of the node within the kubernetes cluster that would act as the server and client respectively.

The workflow measures the link speed from the node allocated as the client to the node allocated as the server. An example plot for such a benchmark run is shown below.

<img src="https://user-images.githubusercontent.com/33978990/92874220-7315d780-f425-11ea-96af-c9aa9239a649.png" height="300" width="450" />

### `fio`
```bash
$ popper run -f workflows/fio.yml -s _HOSTNAME=<hostname-to-benchmark>
```
The `fio` benchmark workflow generates graphs showing the bandwidth, latency and IOPS of of the candidate
blockdevices at varying IO depths and readwrite modes. The plot shown below is obtained by benchmarking the sequential reads of a blockdevice at IO depth 32 with 1m blocksize and 8 jobs.

<img src="https://user-images.githubusercontent.com/33978990/92878167-7b701180-f429-11ea-9a61-0f7bda767961.png" height="300" width="450" />

## Cleaning up the Kubernetes cluster

Once done with running the workflows and performing experiments, it is absolutely necessary to cleanup the ceph partitions and metadata directories created by Rook on the
underlying drives of the nodes in order to be able to deploy and use Ceph again. If the underlying drives are not cleaned up, further Ceph deployments using Rook might not be possible.
[This](https://github.com/rook/rook/blob/master/Documentation/ceph-teardown.md) guide consists of the commands that need to be run on all the nodes of the Kubernetes cluster which were used by a previous Ceph deployment.
A short form of that is available [here]().