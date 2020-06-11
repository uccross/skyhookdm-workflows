import psutil as PSUTIL 
with open('/tmp/cpu_utils', "w") as myfile:
    while True:
        myfile.write(str(PSUTIL.cpu_percent(interval=1))+' ')
        myfile.flush()