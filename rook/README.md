# SkyhookDM-Benchmarks Workflow

Popper workflow to automate large scale tests in SkyhookDM Ceph

## install popper
```bash
$ pip install popper
```

## environment variables
```bash
# generate the .env file and populate it
$ cp .env.example .env 

# apply the environment variables to your shell
$ source .env
```

## prometheus monitoring
```bash
# setup monitoring
$ popper run -f workflows/prometheus.yml setup

# teardown monitoring
$ popper run -f workflows/prometheus.yml teardown
```

## rados and osd benchmarks
```bash
$ popper run -f workflows/ceph_benchmarks.yml 
```

The rados benchmark workflow plots the latency and bandwidth of the rados object store at varying IO depths over a period of 120 seconds for write, read and sequential workloads. An example plot is shown below.

<img src="https://user-images.githubusercontent.com/33978990/86970919-e123f100-c18d-11ea-9baf-2fb7656e23e5.png" height="250" width="350" />

Each of the OSD's are also benchmarked using the native ceph osd benchmark tool, `ceph tell`. 
Both bandwidth (throughput) and IOPS is measured. An example OSD benchmark plot is shown below.

<img src="https://user-images.githubusercontent.com/33978990/86971224-6c04eb80-c18e-11ea-90d2-59d9e762149a.png" height="250" width="350" />


## kubestone benchmarks

The `fio` and `iperf` benchmarks require [`kubestone`](https://kubestone.io/en/latest/) to be installed and a `kubestone` namespace to be created in the cluster.
Please follow the instructions given [here](https://kubestone.io/en/latest/quickstart/#installation) to install kubestone in the cluster. The namespace can be created by doing [this](https://kubestone.io/en/latest/quickstart/#namespace).

### iperf
```bash
$ popper run -f workflows/iperf.yml
```

### `fio`
```bash
$ popper run -f workflows/fio.yml
```
The `fio` benchmark workflow generates graphs showing the bandwidth, latency and IOPS of of the candidate
blockdevices at varying IO depths and readwrite modes. The plot given below is from benchmarking the reads of a blockdevice at IO depth 16.

<img src="https://user-images.githubusercontent.com/33978990/86969921-29421400-c18c-11ea-96de-0e58f7936527.png" height="250" width="350" />
