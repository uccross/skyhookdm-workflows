# SkyhookDM-Benchmarks Workflow

Popper workflow to automate large scale tests in SkyhookDM

## install popper
```bash
$ pip install popper
```

## environment variables
```bash
$ cp .env.example .env 
# then populate the .env

$ source .env
```

## prometheus monitoring
```bash
# setup monitoring
$ popper run -f workflows/prometheus.yml -w . 'setup prometheus monitoring'

# teardown monitoring
$ popper run -f workflows/prometheus.yml -w . 'teardown prometheus monitoring'
```

## ceph benchmarks
```bash
# start rados and osd tests in client pods
$ popper run -f workflows/ceph-benchmarks.yml -w . --skip 'download results' --skip 'teardown client pods'

# download the results of the tests
$ popper run -f workflows/ceph-benchmarks.yml -w . 'download results'

# teardown the client pods
$ popper run -f workflows/ceph-benchmarks.yml -w . 'teardown client pods'
```

## iperf benchmarks
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

## fio benchmarks

### Installing `kubestone`
The `fio` benchmarks require [`kubestone`](https://kubestone.io/en/latest/`) to be installed and a `kubestone` namespace to be created in the cluster.
Please follow the instructions given [here](https://kubestone.io/en/latest/quickstart/#installation) to install kubestone in the cluster. The namespace can be created by doing [this](https://kubestone.io/en/latest/quickstart/#namespace).

### Running the benchmarks

```bash
$ cd rook/
$ popper run -f workflows/fio.yml
```

## plot graphs
```bash
# plot graphs for all the benchmark tests
$ popper run -f workflows/plot.yml -w .
```
