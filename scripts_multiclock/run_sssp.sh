#!/bin/bash

DIR=/home/ssd/yi/scripts_multiclock
BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs
BENCH_RUN="numactl --cpunodebind=0 ${BIN}/sssp -f ${GRAPH_DIR}/web.wsg"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="sssp" 

function func_prepare() {
    killall ${BENCH_NAME}
    
    echo 3 > /proc/sys/vm/drop_caches

	DATE=$(date +%Y%m%d%H%M)

    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}
}

function func_main() {
    TIME="/usr/bin/time"
    echo "Date: ${DATE}"

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/before_vmstat.log 
	cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 

    # ./memory_stat.sh ${LOG_DIR} &
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log 

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
    # killall -9 memory_stat.sh
}

################################ Main ##################################

# 测量2次看看稳定否
# for i in {1..2};
# do
# 	VER="static-${i}"
    VER="1-16"
	func_prepare
	func_main
    # killall -9 pcm-memory
# done

