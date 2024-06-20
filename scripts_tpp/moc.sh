#!/bin/bash

DIR=/home/ssd/yi/scripts_tpp
BIN=/home/ssd/yi/workloads/SimpleMOC/src
BENCH_RUN="${BIN}/SimpleMOC -t 56"
BENCH_NAME="SimpleMOC"

DATE=""
VER="1-4"
PID=""
LOG_DIR=""

function func_prepare() {
	echo 1 > /sys/kernel/mm/numa/demotion_enabled
    echo 3 > /proc/sys/kernel/numa_balancing

    echo 3 > /proc/sys/vm/drop_caches

	DATE=$(date +%Y%m%d%H%M)

    mkdir -p ${DIR}/logs/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/logs/${BENCH_NAME}/${VER}
}

function func_collaction(){
    sleep 10
    PID=$(pgrep -o ${CMD_NAME})
    echo "---------Collaction ${PID}------------"
    perf mem record --pid=${PID} --phys-data
}

function func_main() {
    TIME="/usr/bin/time"
    echo "Date: ${DATE}"

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/before_vmstat.log 
	cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 

    ./memory_stat.sh ${LOG_DIR} &
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} >> ${LOG_DIR}/output.log 

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
    killall -9 memory_stat.sh
	killall -9 pcm-memory
}

################################ Main ##################################

# for i in {1..2};
# do
	func_prepare
	func_main
# done