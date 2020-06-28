# echo "Starting CPU recording on the client and OSDs..."
osds=$2
for ((i = 0 ; i < osds ; i++)); do
    ssh osd${i} "python3 /tmp/get_cpu_utils.py;" &
done;
python3 get_cpu_utils.py &

# echo "Running the experiment..."
client_band=$(python3 skyhook_bandwidth.py a ${1} ${3})

# printf client0:
client_util=$(python3 calc_cpu_utils.py)


# echo "Stopping CPU recording on the client and OSDs..."
for ((i = 0 ; i < osds ; i++)); do
    ssh osd${i} "pkill -f get_cpu_utils.py;" 2> /dev/null
done;
pkill -f get_cpu_utils.py 2> /dev/null &
wait get_cpu_utils.py 2>/dev/null

# echo "Reporting CPU utlizations..."
osd_last_index=$((osds-1))
osd_utils_str=""
for osd_index in $(seq 0 $osd_last_index)
do
    result=$(ssh osd${osd_index} "python3 /tmp/calc_cpu_utils.py;")
    osd_utils_str="$osd_utils_str, $result"
done;

echo "$client_util, $client_band$osd_utils_str"
