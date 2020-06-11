import re
import numpy as np
f = open('/tmp/cpu_utils')
line = f.read()
arr = []
for i in line.split(' '):
    if re.match(r'^-?\d+(?:\.\d+)?$', i) is not None:
        arr.append(float(i))

avg = sum(arr)/len(arr)
print("CPU utilization: " + str(avg) + " %")
