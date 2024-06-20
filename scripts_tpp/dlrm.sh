#!/bin/bash

DIR=/home/ssd/yi/scripts_tpp

BIN=/home/ssd/yi/workloads/dlrm
BENCH_RUN="${BIN}/dlrm_s_criteo_kaggle.sh"

DATE=""
VER="1-4"
PID=""
LOG_DIR=""
BENCH_NAME="dlrm" 

function func_prepare() {
    echo 1 > /sys/kernel/mm/numa/demotion_enabled
	echo 3 > /proc/sys/kernel/numa_balancing

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

    ./memory_stat.sh ${LOG_DIR} &
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log 

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
