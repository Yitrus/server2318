#!/bin/bash

TARGET=$1

while :
do
    if ! pgrep -x "pr" > /dev/null
    then
        echo "Thread masim not found. Exiting loop."
        break
    fi

    cat /proc/vmstat | grep -e pgmig >> /home/ssd/yi/scripts_rl/results/pr/5GB-v42-collect/migrate.txt  
    # numastat -p $(pgrep masim) >> /home/ssd/yi/migrate.txt  
    python test_ratio.py
    rm perf.data

    # sleep 1
done