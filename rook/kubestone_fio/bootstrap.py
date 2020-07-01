import os
import argparse
import yaml


config_dir = './kubestone_fio'


def get_pv_defination(name, size, blockdevice, hostname):
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


def get_pvc_defination(name, size, blockdevice):
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


def get_job_defination(blockdevice):

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
                            "image": "xridge/fio:3.13",
                            "command": ["sleep", "100000"],
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


def write_definations(size, blockdevice, hostname):
    pv_defination = []
    pvc_defination = []
    job_defination = None
    for dev in blockdevice:
        pv_defination.append(
            yaml.dump(get_pv_defination(
                f"pv-{dev}", size, dev, hostname
            ))
        )
        pvc_defination.append(
            yaml.dump(get_pvc_defination(
                f"pvc-{dev}", size, dev
            ))
        )

    job_defination = yaml.dump(get_job_defination(blockdevice))
    pv_defination = "---\n".join(pv_defination)
    pvc_defination = "---\n".join(pvc_defination)

    with open(os.path.join(config_dir, 'pv.yaml'), 'w') as f:
        f.write(pv_defination)

    with open(os.path.join(config_dir, 'pvc.yaml'), 'w') as f:
        f.write(pvc_defination)

    with open(os.path.join(config_dir, 'job.yaml'), 'w') as f:
        f.write(job_defination)


if __name__ == "__main__":
    write_definations(os.environ["PV_SIZE"], os.environ["BLOCKDEVICES"].split(" "), os.environ["HOSTNAME"])
