#!/bin/bash

while :
do
    /home/ssd/yi/tools/pcm-202403/build/bin/pcm-power -p -1 | grep -e Consumed >> ./power.txt & 
    sleep 2
    pcm_power_pid=$(pgrep -o -f "/home/ssd/yi/tools/pcm-202403/build/bin/pcm-power -p -1")
    echo "-----${pcm_power_pid}____"
    kill -9 $pcm_power_pid
    echo "===" >> ./power.txt
    
    /home/ssd/yi/tools/pcm-202403/build/bin/pcm-memory | grep -e NODE >> ./bw.txt &
    sleep 2
    pgrep -f "pcm"| xargs ps -fp
    echo "------------------------------------"
    pgrep -f "/home/ssd/yi/tools/pcm-202403/build/bin/pcm-power -p -1"
    pcm_memory_pid=$(pgrep -o -f "/home/ssd/yi/tools/pcm-202403/build/bin/pcm-memory")
    kill -9 $pcm_memory_pid
    echo "===" >> ./bw.txt
    sleep 20
done