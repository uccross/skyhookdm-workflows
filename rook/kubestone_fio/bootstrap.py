import os
import argparse
import yaml


config_dir = './kubestone_fio'


def get_pv_definition(name, size, blockdevice, hostname):
    pv = {
        "kind": "PersistentVolume",
        "apiVersion": "v1",
        "metadata": {
            "name": name
        },
        "spec": {
            "persistentVolumeReclaimPolicy": "Delete",
            "accessModes": [
                "ReadWriteOnce"
            ],
            "volumeMode": "Block",
            "capacity": {
                "storage": size
            },
            "local": {
                "path": f"/dev/{blockdevice}"
            },
            "nodeAffinity": {
                "required": {
                    "nodeSelectorTerms": [{
                        "matchExpressions": [{
                            "key": "kubernetes.io/hostname",
                            "operator": "In",
                            "values": [
                                hostname
                            ]
                        }]
                    }]
                }
            }
        }
    }
    return pv


def get_pvc_definition(name, size, blockdevice):
    pvc = {
        "kind": "PersistentVolumeClaim",
        "apiVersion": "v1",
        "metadata": {
            "name": name
        },
        "spec": {
            "accessModes": [
                "ReadWriteOnce"
            ],
            "volumeMode": "Block",
            "volumeName": f"pv-{blockdevice}",
            "resources": {
                "requests": {
                    "storage": size
                }
            }
        }
    }
    return pvc


def get_job_definition(blockdevice):

    volumeDevices = []
    for dev in blockdevice:
        volumeDevices.append({"name": f"pvc-{dev}", "devicePath": f"/dev/{dev}"})

    volumes = []
    for dev in blockdevice:
        volumes.append({"name": f"pvc-{dev}", "persistentVolumeClaim": {"claimName": f"pvc-{dev}"}})

    job = {
        "apiVersion": "batch/v1",
        "kind": "Job",
        "metadata": {
            "name": "fio-benchmarks"
        },
        "spec": {
            "template": {
                "metadata": {
                    "labels": {
                        "app": "fio-benchmarks"
                    }
                },
                "spec": {
                    "containers": [
                        {
                            "name": "fio-container",
                            "image": "getpopper/fio-plot:3.12-2",
                            "command": ["sleep", "infinity"],
                            "volumeDevices": volumeDevices,
                            "securityContext": {
                                "privileged": True
                            }
                        }
                    ],
                    "restartPolicy": "Never",
                    "volumes": volumes
                }
            }
        }
    }
    return job


def write_definitions(size, blockdevice, hostname):
    pv_definition = []
    pvc_definition = []
    job_definition = None
    for dev in blockdevice:
        pv_definition.append(
            yaml.dump(get_pv_definition(
                f"pv-{dev}", size, dev, hostname
            ))
        )
        pvc_definition.append(
            yaml.dump(get_pvc_definition(
                f"pvc-{dev}", size, dev
            ))
        )

    job_definition = yaml.dump(get_job_definition(blockdevice))
    pv_definition = "---\n".join(pv_definition)
    pvc_definition = "---\n".join(pvc_definition)

    with open(os.path.join(config_dir, 'pv.yaml'), 'w') as f:
        f.write(pv_definition)

    with open(os.path.join(config_dir, 'pvc.yaml'), 'w') as f:
        f.write(pvc_definition)

    with open(os.path.join(config_dir, 'job.yaml'), 'w') as f:
        f.write(job_definition)


if __name__ == "__main__":
    write_definitions(os.environ["PV_SIZE"], os.environ["BLOCKDEVICES"].split(" "), os.environ["HOSTNAME"])
