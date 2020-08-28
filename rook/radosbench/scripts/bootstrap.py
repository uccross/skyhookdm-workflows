import os
import yaml


config = {
    "apiVersion": "v1",
    "kind": "Pod",
    "metadata": {"name": "ceph-benchmarks", "labels": {"app": "ceph-benchmarks"}},
    "spec": {
        "restartPolicy": "Never",
        "containers": [
            {
                "name": "ceph-benchmarks",
                "image": "uccross/skyhookdm-ceph:v14.2.9",
                "command": ["sleep", "infinity"],
                "securityContext": {
                    "privileged": True
                }
            }
        ],
    },
}

if __name__ == "__main__":
    if os.environ.get("CLIENT", None):
        config["spec"]["nodeSelector"] = {
            "kubernetes.io/hostname": os.environ["CLIENT"]
        }
    with open(os.path.join("./radosbench/deployment.yaml"), "w") as f:
        f.write(yaml.dump(config))
