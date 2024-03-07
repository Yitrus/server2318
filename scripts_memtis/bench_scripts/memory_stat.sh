#!/bin/bash

TARGET=$1

while :
do
    cat /sys/fs/cgroup/htmm/memory.stat | grep -e anon_thp -e anon >> ${TARGET}/memory_stat.txt
    cat /sys/fs/cgroup/htmm/memory.hotness_stat >> ${TARGET}/hotness_stat.txt
    cat /proc/vmstat | grep pgmigrate_su >> ${TARGET}/pgmig.txt
    numastat -m | grep -e Mem -e Dir -e PageTab -e Write -e FileP -e AnonP >> ${TARGET}/numa_use.txt  # 新添加的，看看每个节点容量变化
    sleep 5  # 时间原本1s
done
