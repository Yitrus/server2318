#!/bin/bash

DIR=/home/ssd/yi/scripts_multiclock
BIN=/home/ssd/yi/workloads/SimpleMOC/src
BENCH_RUN="numactl --cpunodebind=0 ${BIN}/SimpleMOC -t 56"
BENCH_NAME="SimpleMOC"
CMD_NAME="simplemoc" # 猜的
DATE=""
VER=""
PID=""
LOG_DIR=""

function func_prepare() {
    echo 3 > /proc/sys/vm/drop_caches

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
    killall ${CMD_NAME}
}

################################ Main ##################################

# for i in {1..2};
# do
# 	VER="G-${i}"
    VER="effi"
	func_prepare
	func_main
# done