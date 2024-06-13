#!/bin/bash

TARGET=$1

while :
do

    #这是带宽、电力消耗的
    # sleep 16

    # /home/ssd/yi/tools/pcm-202403/build/bin/pcm-power -p -1 | grep -e Consumed >> ${TARGET}/power.txt & 
    # sleep 3
    # pcm_power_pid=$(pgrep -o -f "/home/ssd/yi/tools/pcm-202403/build/bin/pcm-power -p -1")
    # kill -9 $pcm_power_pid
    # echo "===" >> ${TARGET}/power.txt
    
    # /home/ssd/yi/tools/pcm-202403/build/bin/pcm-memory | grep -e NODE >> ${TARGET}/bw.txt &
    # sleep 2
    # pcm_memory_pid=$(pgrep -o -f "/home/ssd/yi/tools/pcm-202403/build/bin/pcm-memory")
    # kill -9 $pcm_memory_pid
    # echo "===" >> ${TARGET}/bw.txt
   
    # cat /sys/fs/cgroup/htmm/memory.stat | grep -e anon_thp -e anon >> ${TARGET}/memory_stat.txt
    # numastat -m | grep -e Mem -e Dir -e PageTab -e Write -e FileP -e AnonP >> ${TARGET}/numa_use.txt  # 新添加的，看看每个节点容量变化
    # 时间原本1s
    
    #!/bin/bash

    cat /sys/fs/cgroup/htmm/memory.stat | grep -e anon_thp -e anon >> ${TARGET}/memory_stat.txt
    cat /sys/fs/cgroup/htmm/memory.hotness_stat >> ${TARGET}/hotness_stat.txt
    cat /proc/vmstat | grep -e pgmigrate_su -e htmm_nr_ -e thp_migration_su >> ${TARGET}/pgmig.txt
    sleep 1

done