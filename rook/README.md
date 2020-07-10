# SkyhookDM-Benchmarks Workflow

Popper workflow to automate Large-scale tests and benchmarks of SkyhookDM-Ceph in a Kubernetes cluster.

## Installing popper
```bash
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install popper
```

## Environment variables
```bash
# generate the .env file and populate it
$ cp .env.example .env 

# apply the environment variables to your shell
$ source .env
```

## Setting up skyhookDM cluster using rook
```bash
# setup the cluster
$ popper run -f workflows/setup_rook_cluster.yml setup-rook-cluster

# download the ceph configuration files
$ popper run -f workflows/setup_rook_cluster.yml download-ceph-config

# teardown the cluster
$ popper run -f workflows/setup_rook_cluster.yml teardown-rook-cluster
```

## Setup prometheus monitoring
```bash
# setup monitoring
$ popper run -f workflows/setup_prometheus.yml setup

# teardown monitoring
$ popper run -f workflows/setup_prometheus.yml teardown
```

## Rados and OSD benchmarks
```bash
$ popper run -f workflows/ceph_benchmarks.yml 
```

The rados benchmark workflow plots the latency and bandwidth of the rados object store at varying IO depths over a period of 120 seconds for write, read and sequential workloads. Example rados benchmark plots are shown below.

<img src="https://user-images.githubusercontent.com/33978990/86970919-e123f100-c18d-11ea-9baf-2fb7656e23e5.png" height="250" width="350" />

<img src="https://user-images.githubusercontent.com/33978990/86972328-67413700-c190-11ea-8a43-9f3000b94396.png" height="250" width="350" />

Each of the OSD's are also benchmarked using the native ceph osd benchmark tool, `ceph tell`. 
Both bandwidth (throughput) and IOPS is measured. A set of example OSD benchmark plots are shown below.

<img src="https://user-images.githubusercontent.com/33978990/86971224-6c04eb80-c18e-11ea-90d2-59d9e762149a.png" height="250" width="350" />      

<img src="https://user-images.githubusercontent.com/33978990/86971992-c9e60300-c18f-11ea-89ea-436e108ff498.png" height="250" width="350" />

## Run-Query benchmarks
```bash
$ popper run -f workflows/run_query.yml
```

This workflows run queries over tpch dataset at 1%, 10%, 100% selectivity in arrow (currently not supported) and flatbuffer format and plots the run time of the queries against selectivity. An example plot is shown below.

<img src="https://user-images.githubusercontent.com/33978990/87318524-1772bf00-c546-11ea-8cad-66c5efbc7b8a.png" height="250" width="350">

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

<img src="https://user-images.githubusercontent.com/33978990/87332356-0da68700-c559-11ea-9a03-6af9beb11c3c.png" height="300" width="450" />

### `fio`
```bash
$ popper run -f workflows/fio.yml
```
The `fio` benchmark workflow generates graphs showing the bandwidth, latency and IOPS of of the candidate
blockdevices at varying IO depths and readwrite modes. The plot shown below is obtained by benchmarking the reads of a blockdevice at IO depths 16 and 1.

<img src="https://user-images.githubusercontent.com/33978990/86969921-29421400-c18c-11ea-96de-0e58f7936527.png" height="300" width="450" />

<img src="https://user-images.githubusercontent.com/33978990/86972712-ffd7b700-c190-11ea-8276-ded3c73269ec.png" height="300" width="450" />
