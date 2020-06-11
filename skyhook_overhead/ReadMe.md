### Prepare the RamDisk Ceph Environment with 4 osds, each has 100GB of RAMDisk:
bash ramdisk_ceph.sh 4 myclusterkey.id_rsa  ubuntu 

### Install Dependencies:
bash install_skyhookdmdriver.sh;
bash prepare.sh;

### Generate Arrow Table Data (2000MB's Arrow Table):
python3 data_gen.py 2000

### Run Experiment (4 writers):
run_experiment.sh 4
