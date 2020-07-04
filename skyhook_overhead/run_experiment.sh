# echo "Starting CPU recording on the client and OSDs..."
osds=$2
for ((i = 0 ; i < osds ; i++)); do
    ssh osd${i} "python3 /tmp/get_cpu_utils.py;" &
done;
python3 get_cpu_utils.py &

echo "Running the experiment ${1} ${3}s with object size: ${5} MB"
result_path=${6}
mkdir -p ${result_path}
python3 skyhook_bandwidth.py ${4} ${1} ${3} ${5} ${result_path}
echo "Done."
# printf client0:
# client_util=$(python3 calc_cpu_utils.py)

mv /tmp/cpu_utils "client_${5}_${1}_${3}_cpu_utils"

echo "Stopping CPU recording on the client and OSDs..."
for ((i = 0 ; i < osds ; i++)); do
    ssh osd${i} "pkill -f get_cpu_utils.py;" 2> /dev/null
done;
pkill -f get_cpu_utils.py 2> /dev/null &
wait get_cpu_utils.py 2>/dev/null

# echo "Reporting CPU utlizations..."
for osd_index in $(seq 0 $osd_last_index)
do
    file_name="${result_path}osd${osd_index}_${5}_${1}_${3}_cpu_utils"
    scp osd${osd_index}:/tmp/cpu_utils $file_name
done;
