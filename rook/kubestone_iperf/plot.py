import os
import json
import matplotlib.pyplot as plt

results_dir = './kubestone_iperf/results'

files = os.listdir(results_dir)

legend = []

for file in files:
    if not file.endswith('.json'): continue
    legend.append(file[:-5])
    with open(os.path.join(results_dir, file)) as f:
        results = json.load(f)

    seconds = []
    bandwidth = []

    for run in results["intervals"]:
        seconds.append(float(run["sum"]["end"]))
        bandwidth.append(float(run["sum"]["bits_per_second"])/(1000*1000))

    plt.plot(seconds, bandwidth, markersize=10, linewidth=3.0)

plt.xlabel('time (in seconds)')
plt.ylabel('bandwidth (mb/s)')
plt.title('iperf benchmarks')
plt.legend(legend)
plt.savefig(os.path.join(results_dir, './iperf-benchmarks.png'), dpi=300, bbox_inches='tight')
