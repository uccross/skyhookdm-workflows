# Deploy Ceph (+SkyhookDM) on CloudLab

A workflow for deploying Ceph on CloudLab using `geni-lib` and 
Ansible; assumes basic knowledge of how these two tools work.

The workflow in [`wf.yml`](./wf.yml) deploys Ceph on a 
[Cloudlab][cloudlab] allocation using [`ceph-ansible`][ca]. The 
workflow consists of the following steps:

  * **`allocate resources`**. Request for resources to CloudLab and 
    wait for them to be instantiated. The configuration is specified 
    in the [`geni/config.py`](./geni/config.py)

  * **`generate ansible inventory`**. Generates an Ansible inventory 
    out of the GENI manifest produced by the previous `allocate 
    resources` step. This is used by the subsequent `deploy` step.

  * **`deploy`**. Deploys Ceph by running a playbook from the 
    [`ansible/playbooks/`](./ansible/playbooks) folder. After this 
    step executes, the resulting `ceph.conf` file is placed in 
    [`ansible/fetch/`](./ansible/fetch).

  * **`download and extract skyhook library/download and extract skyhook-arrow library`**. Extracts the
    SkyhookDM and SkyhookDM-Arrow shared libraries from their respective Docker images into the [`ansible/files`](./ansible/files) directory.

  * **`deploy skyhook library`**. Copies the shared libraries from [`ansible/files`](./ansible/files) into the `/usr/lib64/rados-classes/` directory in the Ceph OSDs by running [this](./ansible/deploy-libcls_tabular.yml) playbook.

  * **`release resources`**. Releases all the resources spawned by the workflow.

In addition to the above, subsequent steps can be added to the 
workflow in order to run tests, benchmarks or other workloads that 
work on Ceph. Take a look at the [`test`](../../test) folder for 
examples. This workflow also includes a (commented out) `teardown` 
step that releases the allocated resources in CloudLab and can be 
invoked to release resources.

## Usage

To execute this workflow:

 1. Clone this repository or copy the contents of this folder into 
    your project:

    ```bash
    git clone https://github.com/uccross/skyhookdm-workflows
    cd skyhookdm-workflows/cloudlab
    ```

 2. Define the secrets expected by the workflow, declared in the 
    `secrets` attribute of steps:

    ```bash
    export GENI_FRAMEWORK=emulab-ch2
    export GENI_PROJECT=<project>
    export GENI_USERNAME=<username>
    export GENI_KEY_PASSPHRASE='<password>'
    export GENI_PUBKEY_DATA=$(cat ~/.ssh/id_rsa.pub | base64)
    export GENI_CERT_DATA=$(cat ~/.ssh/cloudlab.pem | base64)

    export ANSIBLE_SSH_KEY_DATA=$(cat ~/.ssh/id_rsa | base64)
    ```

    See [the GENI image README][gd] for more information about the 
    secrets related to the GENI steps; similarly [here][cad] for the 
    Ansible step. **NOTE:** the value of `GENI_PROJECT` is expected
    to be all lower case.

 3. Tweak the following to your needs:

     * The experiment name in the [GENI config 
       file](./geni/config.py). Changing the name of the experiment 
       avoids having another member of your project running the script 
       and resulting in name clashes.

     * The number of nodes, and how they are to be grouped in terms of 
       their roles (`osd`, `mon`, `rgw`, etc.). This is also specified 
       in the GENI [config file](./geni/config.py).

     * Specify in the `deploy` step which Ansible playbook is to be 
       executed (see the [`ansible/playbooks/`](./ansible/playbooks) 
       folder. Multiple playbooks may exist, depending on what type of 
       deployment is needed (e.g. ).

     * Tweak Ceph variables for the cluster available in the 
       [`ansible/group_vars`](./ansible/group_vars) folder.

 4. Execute the workflow by doing:

    ```bash
    popper run -f wf.yml
    ```

For more information on Popper, visit 
<https://github.com/systemslab/popper>.

[cloudlab]: https://cloudlab.us
[ca]: https://github.com/ceph/ceph-ansible
[gd]: https://github.com/getpopper/library/tree/master/geni
[cad]: https://github.com/getpopper/library/tree/master/ansible
[ca-docs]: http://docs.ceph.com/ceph-ansible/master/
