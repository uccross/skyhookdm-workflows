echo "Starting CPU recording on the client and OSDs..."
for ((i = 0 ; i < 4 ; i++)); do
    ssh osd${i} "python3 /tmp/get_cpu_utils.py;" &
done;
python3 get_cpu_utils.py &

echo "Running the experiment..."
python3 skyhook_bandwidth.py a ${1}

echo "Stopping CPU recording on the client and OSDs..."
for ((i = 0 ; i < 4 ; i++)); do
    ssh osd${i} "pkill -f get_cpu_utils.py;" 2> /dev/null
done;
pkill -f get_cpu_utils.py 2> /dev/null &
wait get_cpu_utils.py 2>/dev/null

echo "Reporting CPU utlizations..."
for ((i = 0 ; i < 4 ; i++)); do
    printf osd${i}:
    ssh osd${i} "python3 /tmp/calc_cpu_utils.py;"
done;
printf client0:
python3 calc_cpu_utils.py
