for ((i = 0 ; i < 4 ; i++)); do

    ssh osd${i} "sudo apt-get update;sudo apt-get install python3-pip -y; sudo pip3 install psutil; sudo pip3 install numpy;"
    scp ./get_cpu_utils.py $USER@osd${i}:/tmp/
    scp ./calc_cpu_utils.py $USER@osd${i}:/tmp/

done;
    
    
