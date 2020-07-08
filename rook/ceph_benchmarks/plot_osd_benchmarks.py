import os
import json

import matplotlib.pyplot as plt


results_dir = './ceph_benchmarks/results'


def read_output_file(filename):
    with open(os.path.join(results_dir,filename), 'r') as f:
        data = json.loads(f.read()) 

    througput = data['bytes_per_sec']/(1024*1024)
    iops = data['iops']
    return (througput, iops)


def find_osd_count():
    count = 0
    files = os.listdir(results_dir)
    for filename in files:
        if filename.startswith('osd.'):
            count += 1
    return count

if __name__ == "__main__":
    througputs = []
    iops_list = []
    osds = []
    osd_count = find_osd_count()
    for i in range(0, osd_count):
        osds.append(f'osd.{i}')

    for osd in osds:
        throughput, iops = read_output_file(f'{osd}.json')
        througputs.append(throughput)
        iops_list.append(iops)

    plt.xlabel('osd')
    plt.ylabel('throughput (mb/s)')
    plt.title('osd throughput bechmarks')
    plt.bar(osds, througputs, color="green")
    plt.savefig(os.path.join(results_dir, 'osd_throughput_benchmarks.png'), dpi=300, bbox_inches='tight')
    plt.cla()
    plt.clf()

    plt.xlabel('osd')
    plt.ylabel('iops')
    plt.title('osd iops benchmarks')
    plt.bar(osds, iops_list, color="blue")
    plt.savefig(os.path.join(results_dir, 'osd_iops_benchmarks.png'), dpi=300, bbox_inches='tight')
