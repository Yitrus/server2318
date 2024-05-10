#!/bin/bash

DIR=/home/ssd/yi/scripts_tpp
BIN=/home/ssd/yi/workloads/XSBench/openmp-threading
BENCH_RUN="numactl --membind=0,2 ${BIN}/XSBench -t 20 -g 130000 -p 30000000"
BENCH_NAME="XSBench"
# BIN=/home/ssd/yi/workload/gapbs
# BENCH_RUN="${BIN}/bc -f ${BIN}/kron.sg"
# BENCH_NAME="gapbs-DRAM"
CMD_NAME="XSBench"
DATE=""
VER=""
PID=""
LOG_DIR=""

function func_prepare() {
    # killall perf
    killall XSBench
	# echo "Preparing benchmark start..."
	echo 1 > /sys/kernel/mm/numa/demotion_enabled
    echo 3 > /proc/sys/kernel/numa_balancing

	DATE=$(date +%Y%m%d%H%M)
    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}
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

    ${DIR}/mem.sh ${LOG_DIR} &
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} >> ${LOG_DIR}/output.log 

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
    sudo killall mem.sh
    killall ${CMD_NAME}
}

################################ Main ##################################

for i in {1..2};
do
	VER="cxl-${i}"
	func_prepare
	func_main
done