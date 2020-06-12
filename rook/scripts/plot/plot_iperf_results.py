import os
import matplotlib.pyplot as plt

with open('/workspace/results/iperf-results.txt') as f:
    results = f.readlines()

hosts = []
bws = []
for result in results:
    hosts.append(result.split(',')[3])
    bws.append(int(result.split(',')[7])/((1000*1000*1000)))

plt.xlabel('Clients\'s')
plt.ylabel('Bandwidth (Gib/s)')
plt.title('Iperf tests')
plt.bar(hosts, bws)
plt.savefig('/workspace/results/outputs/iperf-benchmarks.png', dpi=300, bbox_inches='tight')
