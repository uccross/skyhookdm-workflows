import cloudlab_cmd

# name of experiment to use to identify this allocation
experiment_name = 'popper-ceph'

# expiration of allocation in minutes
expiration = 180

# OS image to use
img = "urn:publicid:IDN+clemson.cloudlab.us+image+schedock-PG0:ubuntu18-docker"

# check availability and types at https://www.cloudlab.us/resinfo.php
site = 'clemson'
hw_type = 'c6320'

# create an internal network
with_lan = True

############
# multi-node
############
# grouping of nodes based on their ceph roles
num_osds = 3
groups = {
   'mons': ['mon1'],
   'mgrs': ['mon1'],
   'osds': ['osd{}'.format(n) for n in range(1, num_osds+1)],
}


#############
# single node
#############
#groups = {
#    'mons': ['onlynode'],
#    'osds': ['onlynode'],
#    'mgrs': ['onlynode'],
#}


#############
# run command (parse 'apply', 'destroy', 'get-inventory' and 'renew'
#############
cloudlab_cmd.run(experiment_name, expiration, site, groups, hw_type, img,
                 with_lan)
