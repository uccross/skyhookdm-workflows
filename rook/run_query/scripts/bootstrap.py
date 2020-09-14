import os
import yaml


config = {
    "apiVersion": "v1",
    "kind": "Pod",
    "metadata": {"name": "run-query", "labels": {"app": "run-query"}},
    "spec": {
        "restartPolicy": "Never",
        "containers": [
            {
                "name": "run-query",
                "image": "uccross/skyhookdm-ceph:v14.2.9",
                "command": ["sleep", "infinity"],
                "env": [
                    {"name": "POOLTYPE", "value": "replicated"},
                    {"name": "LD_LIBRARY_PATH", "value": "/usr/lib64/ceph"},
                ],
                "securityContext": {"privileged": True},
            }
        ],
    },
}

if __name__ == "__main__":
    if os.environ.get("CLIENT", None):
        config["spec"]["nodeSelector"] = {
            "kubernetes.io/hostname": os.environ["CLIENT"]
        }
    with open(os.path.join("./run_query/pod.yaml"), "w") as f:
        f.write(yaml.dump(config))
