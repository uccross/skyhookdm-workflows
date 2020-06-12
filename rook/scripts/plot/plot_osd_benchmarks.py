import os
import json

import matplotlib.pyplot as plt

if not os.path.exists('/workspace/results/outputs'):
    os.makedirs('/workspace/results/outputs')

results_dir = '/workspace/results'

def read_output_file_and_plot(filename):
    with open(os.path.join(results_dir,filename), 'r') as f:
        data = json.loads(f.read()) 

    througput = data['bytes_per_sec']/(1024*1024)
    return througput

if __name__ == "__main__":
    througputs = []
    osds = []
    osd_count = 8
    for i in range(0, osd_count):
        osds.append(f'osd.{i}')

    for osd in osds:
        througputs.append(read_output_file_and_plot(f'{osd}.json'))

    plt.xlabel('OSD\'s')
    plt.ylabel('Throughput (MB/s)')
    plt.title('OSD Bechmarks')
    plt.bar(osds, througputs)
    plt.savefig('/workspace/results/outputs/osd-benchmarks.png', dpi=300, bbox_inches='tight')
