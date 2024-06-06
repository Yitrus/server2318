#!/bin/bash

TARGET=$1

while :
do
    if ! pgrep -x "masim" > /dev/null
    then
        echo "Thread masim not found. Exiting loop."
        break
    fi

    cat /proc/vmstat | grep -e pgmig >> /home/ssd/yi/scripts_memtis/results/masim_s8/16GB/migrate.txt  
    python test_ratio.py
    rm perf.data

    # sleep 1
done