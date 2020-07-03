import os
import json
import numpy as np

import matplotlib.pyplot as plt


results_dir = './ceph_benchmarks/results'


def plot_bw(filenames, line_colors):
    results = {
        'write_data': None,
        'seq_data': None,
        'rand_data': None
    }

    for filename, line_color in zip(filenames, line_colors):
        with open(os.path.join(results_dir, filename), 'r') as f:
            results[f'{filename[:-5]}_data'] = json.loads(f.read())['datas']  

        x = list()
        y = list()
        for itr in results[f'{filename[:-5]}_data']:
            x.append(int(itr['sec']))
            y.append(float(itr['avg_bw']))
            
        plt.plot(x, y, markersize=10, linewidth=3.0, color=line_color)

    plt.legend(['write', 'sequential', 'random'])
    plt.xlabel('seconds')
    plt.ylabel('avg. bandwidth')
    plt.title('rados bandwidth bechmarks')
    plt.savefig(os.path.join(results_dir, 'rados_bw_bench.png'), dpi=300, bbox_inches='tight')
    plt.cla()
    plt.clf()


def plot_latencies(filenames):
    min_lat = []
    avg_lat = []
    max_lat = []

    for filename in filenames:
        with open(os.path.join(results_dir, filename), 'r') as f:
            data = json.loads(f.read())
            min_lat.append(data['min_latency'])
            avg_lat.append(data['average_latency'])
            max_lat.append(data['max_latency'])

    labels = ['write', 'seq', 'read']

    x = np.arange(len(labels))
    width = 0.35

    fig, ax = plt.subplots()
    rects1 = ax.bar(x - width, min_lat, width, label='min')
    rects2 = ax.bar(x, avg_lat, width, label='avg')
    rects3 = ax.bar(x + width, max_lat, width, label='max')

    ax.set_ylabel('latency')
    ax.set_title('rados latency benchmarks')
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()

    fig.tight_layout()
    plt.savefig(os.path.join(results_dir, 'rados_lat_bench.png'), dpi=300, bbox_inches='tight')
    plt.cla()
    plt.clf()


if __name__ == "__main__":
    plot_bw(['write.json', 'seq.json', 'rand.json'], ['red', 'blue', 'green'])
    plot_latencies(['write.json', 'seq.json', 'rand.json'])
