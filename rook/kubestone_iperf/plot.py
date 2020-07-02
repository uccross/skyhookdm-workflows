import os
import json
import matplotlib.pyplot as plt

results_dir = './kubestone_iperf'

with open(os.path.join(results_dir, 'results')) as f:
    results = json.load(f)

seconds = []
bandwidth = []

for run in results["intervals"]:
    seconds.append(float(run["sum"]["end"]))
    bandwidth.append(float(run["sum"]["bits_per_second"])/(1000*1000))

plt.xlabel('time (in seconds)')
plt.ylabel('bandwidth (mb/s)')
plt.title('iperf benchmarks')
plt.bar(seconds, bandwidth)
plt.savefig(os.path.join(results_dir, './iperf-benchmarks.png'), dpi=300, bbox_inches='tight')
