#!/bin/bash

TARGET=$1

while :
do
    if ! pgrep -x "train" > /dev/null
    then
        echo "Thread masim not found. Exiting loop."
        break
    fi

    cat /proc/vmstat | grep -e pgmig >> /home/ssd/yi/migrate.txt  
    # numastat -p $(pgrep masim) >> /home/ssd/yi/migrate.txt  
    python test_ratio.py
    rm perf.data

    # sleep 1
done