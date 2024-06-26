#!/bin/bash

DIR=/home/ssd/yi/scripts_multiclock
BIN=/home/ssd/yi/workloads/ycsb-0.15.0
BENCH_RUN="numactl --cpunodebind=0 ${BIN}/bin/ycsb run memcached -s -P ${BIN}/workloads/workloadd -p "memcached.hosts=127.0.0.1" -p "memcached.port=11211" -p recordcount=1000000000 -p operationcount=125000000 -threads 112"
BENCH_NAME="ycsb_d"
DATE=""
VER=""
PID=""
LOG_DIR=""

function func_prepare() {
	DATE=$(date +%Y%m%d%H%M)

    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}
}

function func_main() {
    TIME="/usr/bin/time"
    echo "Date: ${DATE}"

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/before_vmstat.log 
	cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 

    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} >> ${LOG_DIR}/output.log 

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
}

################################ Main ##################################

# for i in {1..2};
# do
	# VER="G-${i}"
    VER="2-1-2"
	func_prepare
	func_main
# done