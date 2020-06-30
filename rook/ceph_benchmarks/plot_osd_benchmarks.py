import os
import json

import matplotlib.pyplot as plt

results_dir = './ceph_benchmarks/results'

def read_output_file_and_plot(filename):
    with open(os.path.join(results_dir,filename), 'r') as f:
        data = json.loads(f.read()) 

    througput = data['bytes_per_sec']/(1024*1024)
    return througput

def find_osd_count():
    count = 0
    files = os.listdir(results_dir)
    for filename in files:
        if filename.startswith('osd.'):
            count += 1
    return count

if __name__ == "__main__":
    througputs = []
    osds = []
    osd_count = find_osd_count()
    for i in range(0, osd_count):
        osds.append(f'osd.{i}')

    for osd in osds:
        througputs.append(read_output_file_and_plot(f'{osd}.json'))

    plt.xlabel('osd\'s')
    plt.ylabel('throughput (mb/s)')
    plt.title('osd bechmarks')
    plt.bar(osds, througputs)
    plt.savefig(os.path.join(results_dir, 'osd_benchmarks.png'), dpi=300, bbox_inches='tight')
