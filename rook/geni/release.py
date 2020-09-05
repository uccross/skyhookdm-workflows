import os

from geni.aggregate import cloudlab
from geni import util

slice_name = str(os.environ["NODE_SLICE"])

ctx = util.loadContext(
    "/geni-context.json", key_passphrase=os.environ["GENI_KEY_PASSPHRASE"]
)

print("Available slices: {}".format(ctx.cf.listSlices(ctx).keys()))

# identify the cluster
cluster = str(os.environ["NODE_CLUSTER"])
if cluster == "utah":
    cluster = cloudlab.Utah

elif cluster == "wisconsin":
    cluster = cloudlab.Wisconsin

elif cluster == "clemson":
    cluster = cloudlab.Clemson

if util.sliceExists(ctx, slice_name):
    print("Slice exists.")
    print("Removing all existing slivers (errors are ignored)")
    util.deleteSliverExists(cluster, ctx, slice_name)
else:
    print("Slice does not exist.")
