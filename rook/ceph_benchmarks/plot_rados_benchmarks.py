import os
import json

import matplotlib.pyplot as plt

results_dir = './ceph_benchmarks/results'
results = {
    'write_data': None,
    'seq_data': None,
    'rand_data': None
}

def read_output_file_and_plot(filename, line_color):
    with open(os.path.join(results_dir, filename), 'r') as f:
        results[f'{filename[:-5]}_data'] = json.loads(f.read())['datas']  

    x = list()
    y = list()
    for itr in results[f'{filename[:-5]}_data']:
        x.append(int(itr['sec']))
        y.append(float(itr['avg_bw']))
        
    plt.plot(x, y, markersize=10, linewidth=3.0, color=line_color)


if __name__ == "__main__":
    read_output_file_and_plot('write.json', 'red')
    read_output_file_and_plot('seq.json', 'blue')
    read_output_file_and_plot('rand.json', 'green')

    plt.legend(['write', 'sequential', 'random'])
    plt.xlabel('seconds')
    plt.ylabel('avg. bandwidth')
    plt.title('rados bechmarks')
    plt.savefig(os.path.join(results_dir, 'rados_benchmarks.png'), dpi=300, bbox_inches='tight')
