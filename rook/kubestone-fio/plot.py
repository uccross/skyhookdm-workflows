import os
import json
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

result_files = os.listdir('./kubestone-fio/results')

data = defaultdict(dict)

for file in result_files:
    with open(os.path.join('./kubestone-fio/results', file), 'r') as f:
        blockdevice = file.split("-")[1]
        rw  = file.split("-")[2][:-5]
        mode = None
        if rw == "randread" or rw == "read":
            mode = "read"
        elif rw == "randwrite" or rw == "write":
            mode = "write"
        jobdata = json.load(f)
        data[blockdevice][rw] = float(jobdata["jobs"][0][mode]["bw"])/1000

blockdevices = list(data.keys())
writes = []
reads = []
randwrites = []
randreads = []

for key, value in data.items():
    writes.append(value['write'])
    reads.append(value['read'])
    randwrites.append(value['randwrite'])
    randreads.append(value['randread'])

ind = [x for x, _ in enumerate(blockdevices)]

randreads = np.array(randreads)
randwrites = np.array(randwrites)
reads = np.array(reads)
writes = np.array(writes)

plt.bar(ind, randreads, width=0.8, label='randreads', color='#7E5109', bottom=randwrites+reads+writes)
plt.bar(ind, randwrites, width=0.8, label='randwrites', color='gold', bottom=reads+writes)
plt.bar(ind, reads, width=0.8, label='reads', color='#F39C12', bottom=writes)
plt.bar(ind, writes, width=0.8, label='writes', color='#CD853F')

plt.xticks(ind, blockdevices)
plt.ylabel("Bandwidth (mb/s)")
plt.xlabel("block devices")
plt.legend(loc="upper right")
plt.title("fio benchmarks")
plt.savefig('./kubestone-fio/fio-benchmarks.png', dpi=300, bbox_inches='tight')
