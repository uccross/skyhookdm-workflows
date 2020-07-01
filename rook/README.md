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

## ceph (rados and osd) benchmarks
```bash
$ popper run -f workflows/ceph_benchmarks.yml 
```

## kubestone benchmarks

The `fio` and `iperf` benchmarks require [`kubestone`](https://kubestone.io/en/latest/) to be installed and a `kubestone` namespace to be created in the cluster.
Please follow the instructions given [here](https://kubestone.io/en/latest/quickstart/#installation) to install kubestone in the cluster. The namespace can be created by doing [this](https://kubestone.io/en/latest/quickstart/#namespace).

### iperf
```bash
# run the tests
$ popper run -f workflows/iperf.yml run

# download the test results
$ popper run -f workflows/iperf.yml download-results

# teardown the tests
$ popper run -f workflows/iperf.yml teardown

# plot the test results
$ popper run -f workflows/iperf.yml plot-results
```

### fio
```bash
$ popper run -f workflows/fio.yml
```
