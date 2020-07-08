import os
import json
import numpy as np

import matplotlib.pyplot as plt


results_dir = './ceph_benchmarks/results'


def plot(filenames, line_colors, io_depth, param):
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
    plt.xlabel('seconds')
    plt.ylabel(f"{param}")
    plt.title(f"rados - {param} - iodepth {io_depth}")
    plt.savefig(os.path.join(results_dir, f"rados_{param}_bench_iodepth_{io_depth}.png"), dpi=300, bbox_inches='tight')
    plt.cla()
    plt.clf()


if __name__ == "__main__":
    io_depths = os.environ.get("IO_DEPTH").split(" ")
    for io_depth in io_depths:
        plot([f"write-{io_depth}.json", f"seq-{io_depth}.json", f"rand-{io_depth}.json"], ['red', 'blue', 'green'], io_depth, "avg_bw")
        plot([f"write-{io_depth}.json", f"seq-{io_depth}.json", f"rand-{io_depth}.json"], ['red', 'blue', 'green'], io_depth, "avg_lat")
