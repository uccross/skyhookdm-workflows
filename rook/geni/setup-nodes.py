import os

# install packages
os.system('pip install PyYAML xmltodict')

import yaml
import xmltodict

import geni.portal as portal
import geni.rspec.pg as rspec

from geni import util
from geni.aggregate import cloudlab

request = portal.context.makeRequestRSpec()

node_list = list()
node_count = int(os.environ['NODE_COUNT'])

slice_name = str(os.environ['NODE_SLICE'])

# Create the raw "PC" nodes
for _idx in range(0, node_count):
    node = request.RawPC('node_{}'.format(_idx))
    node.hardware_type = str(os.environ['NODE_HARDWARE'])
    node_list.append(node)

# Create a link between them
link1 = request.Link(members=node_list)

# load context
ctx = util.loadContext(path="/geni-context.json",
                       key_passphrase=os.environ['GENI_KEY_PASSPHRASE'])

# create slice
util.createSlice(ctx, slice_name, 300, True)

# identify the cluster
cluster = str(os.environ['NODE_CLUSTER'])
if cluster == 'utah':
    cluster = cloudlab.Utah

elif cluster == 'wisconsin':
    cluster = cloudlab.Wisconsin

elif cluster == 'clemson':
    cluster = cloudlab.Clemson

# create sliver
manifest = util.createSliver(ctx, cluster, slice_name, request)

dict_response = xmltodict.parse(manifest.text)

node_ip_list = list()

for idx in range(0, len(dict_response['rspec']['node'])):
    node_ip_list.append(str(dict_response['rspec']['node'][idx]['host']['@ipv4']))

with open('./geni/hosts', 'w') as f:
    f.write(' '.join(node_ip_list))
