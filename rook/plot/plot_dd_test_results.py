import os
import matplotlib.pyplot as plt
import numpy as np

if not os.path.exists('./results/outputs'):
    os.makedirs('./results/outputs')

results_dir = './results'

data = {}

result_dir_content = os.listdir(results_dir)
for file in result_dir_content:
    if not file.startswith('dd-'):
        continue

    node_hostname = file.split("-")[2]
    node_disk = file.split("-")[1]

    if not data.get(node_hostname):
        data[node_hostname] = list()

    with open(os.path.join(results_dir, file)) as f:
        lines = f.readlines()
        data[node_hostname].append({
            "dev": node_disk,
            "value": float(lines[2].split(',')[3].rstrip()[:-5])
        })

nodes = list(data.keys())
throughput = {}

for node in nodes:
    for x in data[node]:
        if not throughput.get(x['dev']):
            throughput[x['dev']] = list()
        throughput[x['dev']].append(x['value'])

width = 0.15
multiple = 0
for k, v in throughput.items():
    plt.bar(np.arange(len(v)) + (width * multiple), tuple(v), width, label=k)
    multiple += 1

plt.ylabel('Throughput (Mb/s)')
plt.title('DD Tests')

plt.xticks(np.arange(len(throughput[list(throughput.keys())[0]])) + width / 2, tuple(nodes))
plt.legend(loc='best')
plt.savefig('./results/outputs/dd-tests.png', dpi=300, bbox_inches='tight')
