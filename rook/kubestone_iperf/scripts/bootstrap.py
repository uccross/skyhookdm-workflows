import os
import yaml


config_dir = "./kubestone_iperf"


iperf_definition = {
    "apiVersion": "perf.kubestone.xridge.io/v1alpha1",
    "kind": "Iperf3",
    "metadata": {"name": "iperf3-tests"},
    "spec": {
        "image": {"name": "xridge/iperf3:3.7.0", "pullPolicy": "IfNotPresent"},
        "serverConfiguration": {
            "cmdLineArgs": "--json",
            "podLabels": {"iperf-mode": "server"},
            "podScheduling": {
                "affinity": {
                    "nodeAffinity": {
                        "requiredDuringSchedulingIgnoredDuringExecution": {
                            "nodeSelectorTerms": [
                                {
                                    "matchExpressions": [
                                        {
                                            "key": "kubernetes.io/hostname",
                                            "operator": "In",
                                            "values": [os.environ["SERVER"]],
                                        }
                                    ]
                                }
                            ],
                        }
                    }
                }
            },
            "hostNetwork": False,
        },
        "clientConfiguration": {
            "cmdLineArgs": "--json --time 60",
            "podLabels": {"iperf-mode": "client"},
            "podScheduling": {
                "affinity": {
                    "nodeAffinity": {
                        "requiredDuringSchedulingIgnoredDuringExecution": {
                            "nodeSelectorTerms": [
                                {
                                    "matchExpressions": [
                                        {
                                            "key": "kubernetes.io/hostname",
                                            "operator": "In",
                                            "values": [os.environ["CLIENT"]],
                                        }
                                    ]
                                }
                            ],
                        }
                    }
                }
            },
        },
        "udp": False,
    },
}

if __name__ == "__main__":
    with open(os.path.join(config_dir, "iperf.yaml"), "w") as f:
        definition_str = yaml.dump(iperf_definition)
        f.write(definition_str)
