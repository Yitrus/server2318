#!/bin/bash

TARGET=$1

while :
do
    if ! pgrep -x "masim" > /dev/null
    then
        echo "Thread masim not found. Exiting loop."
        break
    fi

    cat /proc/vmstat | grep -e pgmig >> /home/ssd/yi/scripts_multiclock/results/masim_s1/3/migrate.txt  
    # numastat -p $(pgrep masim) >> /home/ssd/yi/migrate.txt  
    python test_ratio.py
    rm perf.data

    # sleep 1
done