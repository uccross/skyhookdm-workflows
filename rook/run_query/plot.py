import json
import os

import matplotlib.pyplot as plt

results_dir = './run_query/results'

with open(os.path.join(results_dir, 'result.json')) as f:
  data = json.loads(f.read())

lineitem_fbx_data = data['lineitem']['fbx']

selectivity = ["1%", "10%", "100%"]
runtime = [float(lineitem_fbx_data["1"]), float(lineitem_fbx_data["10"]), float(lineitem_fbx_data["100"])]

plt.xlabel('selectivity')
plt.ylabel('time taken (s)')

axes = plt.gca()
# axes.set_ylim([1, 5])

plt.title('lineitem flatbuffer benchmarks')
plt.bar(selectivity, runtime, color="blue")
plt.savefig(os.path.join(results_dir, 'lineitem_flatbuffer_benchmarks.png'), dpi=300, bbox_inches='tight')
plt.cla()
plt.clf()