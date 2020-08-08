import os
import json
import numpy as np

import matplotlib.pyplot as plt


results_dir = './radosbench/results'


def plot(filenames, line_colors, thread, param, param_title):
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
            y.append(float(itr[param]))
            
        plt.plot(x, y, markersize=10, linewidth=3.0, color=line_color)

    plt.legend(['write', 'sequential', 'random'])
    plt.xlabel('Seconds')
    plt.ylabel(f"{param_title}")
    plt.title(f"rados - {param} - thread {thread}")
    plt.savefig(os.path.join(results_dir, f"rados_{param}_bench_thread_{thread}.png"), dpi=300, bbox_inches='tight')
    plt.cla()
    plt.clf()


if __name__ == "__main__":
    threads = os.environ.get("THREADS").split(" ")
    for thread in threads:
        plot([f"write-{thread}.json", f"seq-{thread}.json", f"rand-{thread}.json"], ['red', 'blue', 'green'], thread, 'avg_bw', "Bandwidth (MB/s)")
        plot([f"write-{thread}.json", f"seq-{thread}.json", f"rand-{thread}.json"], ['red', 'blue', 'green'], thread, 'avg_lat', "Latency (s)")
