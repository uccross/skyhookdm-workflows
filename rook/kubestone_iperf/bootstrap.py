import os
import yaml


config_dir = './kubestone_iperf'


iperf_defination = {
  "apiVersion": "perf.kubestone.xridge.io/v1alpha1",
  "kind": "Iperf3",
  "metadata": {
    "name": "iperf3-tests"
  },
  "spec": {
    "image": {
      "name": "xridge/iperf3:3.7.0",
      "pullPolicy": "IfNotPresent"
    },
    "serverConfiguration": {
      "cmdLineArgs": "--json",
      "podLabels": {
        "iperf-mode": "server"
      },
      "podScheduling": {
        "affinity": {
          "nodeAffinity": {
            "requiredDuringSchedulingIgnoredDuringExecution": {
              "nodeSelectorTerms": [{
                  "matchExpressions": [{
                      "key": "kubernetes.io/hostname",
                      "operator": "In",
                      "values": [os.environ["SERVER"]]
                  }]
              }],
            }
          }
        }
      },
      "hostNetwork": False,
    },
    "clientConfiguration": {
      "cmdLineArgs": "--json",
      "podLabels": {
        "iperf-mode": "client"
      },
      "podScheduling": {
        "affinity": {
          "nodeAffinity": {
            "requiredDuringSchedulingIgnoredDuringExecution": {
              "nodeSelectorTerms": [{
                  "matchExpressions": [{
                      "key": "kubernetes.io/hostname",
                      "operator": "In",
                      "values": [os.environ["CLIENT"]]
                  }]
              }],
            }
          }
        }
      }
    },
    "udp": False
  }
}

if __name__ == "__main__":
  with open(os.path.join(config_dir, 'iperf.yaml'), 'w') as f:
    defination_str = yaml.dump(iperf_defination)
    f.write(defination_str)
