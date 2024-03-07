#!/bin/bash

# 这个脚本相当于不迁移的情况

function func_collaction(){
    PID=$(pgrep -o bfs)
    echo "---------Collaction ${PID}------------"

    # perf record -F 1 -o ${LOG_DIR}/perf.data -a -g & 
    # perf_pid=$(pgrep -o -f "perf record")
    while kill -0 "${PID}" >/dev/null 2>&1
    do
        cat /proc/vmstat | grep pgmigrate_su >> ${LOG_DIR}/pgmig.txt
        numastat -m | grep -e Mem -e Dir -e PageTab -e Write -e FileP -e AnonP >> ${LOG_DIR}/numa_use.txt  
        sleep 5 
    done
    # kill -SIGINT "$perf_pid"
}


BENCHMARKS="gapbs-bfs"
sudo dmesg -c
killall bfs
killall perf
swapoff -a 
# enable THP
sudo echo "always" | tee /sys/kernel/mm/transparent_hugepage/enabled
sudo echo "always" | tee /sys/kernel/mm/transparent_hugepage/defrag

for BENCH in ${BENCHMARKS};
do
    export GOMP_CPU_AFFINITY=0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38
    
    if [[ -e ./bench_cmds/${BENCH}.sh ]]; then
	source ./bench_cmds/${BENCH}.sh
    else
	echo "ERROR: ${BENCH}.sh does not exist."
	continue
    fi

    mkdir -p results/${BENCH}/all-nvm
    LOG_DIR=results/${BENCH}/all-nvm

    free;sync;echo 3 > /proc/sys/vm/drop_caches;

    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/before_vmstat.log 

	/usr/bin/time -f "execution time %e (s)" \
	    taskset -c 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38 numactl --membind=2 ${BENCH_RUN} 2>&1 \
	    | tee ${LOG_DIR}/output.log  & func_collaction

    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/after_vmstat.log

done
