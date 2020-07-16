import json
import os

import numpy as np
import matplotlib.pyplot as plt


results_dir = './run_query/results'


with open(os.path.join(results_dir, 'result.json')) as f:
  data = json.loads(f.read())


def plot_fbx():
  lineitem_fbx_data = data['lineitem']['fbx']
  lineitem_fbx_cls_data = data['lineitem']['fbx_cls']

  selectivity_1 = (float(lineitem_fbx_data["1"]), float(lineitem_fbx_cls_data["1"]))
  selectivity_10 = (float(lineitem_fbx_data["10"]), float(lineitem_fbx_cls_data["10"]))
  selectivity_100 = (float(lineitem_fbx_data["100"]), float(lineitem_fbx_cls_data["100"]))

  fig = plt.figure()
  ax = fig.add_subplot(111)

  ind = np.arange(2)
  width = 0.2

  rects1 = ax.bar(ind, selectivity_1, width, color='royalblue')
  rects2 = ax.bar(ind+width, selectivity_10, width, color='seagreen')
  rects3 = ax.bar(ind+width+width, selectivity_100, width, color='orange')

  ax.set_ylabel('Time (s)')
  ax.set_title('Query perf over 750K row dataset in fbx format')
  ax.set_xticks(ind + width / 2)
  ax.set_xticklabels( ('Client Side', 'Storage Side') )

  ax.legend((rects1[0], rects2[0], rects3[0]), ('1%', '10%', '100%') )
  plt.savefig(os.path.join(results_dir, 'lineitem_fbx_benchmarks.png'), dpi=300, bbox_inches='tight')
  plt.cla()
  plt.clf()


if __name__ == "__main__":
  plot_fbx()
