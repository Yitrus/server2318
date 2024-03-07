#!/bin/bash

DIR=/home/xmu/Documents/yi
BIN=/home/xmu/Documents/yi/workload/liblinear-multicore-2.47
BENCH_RUN="numactl -N 0 --membind=0,1,2 ${BIN}/train -s 6 -m 20 ${BIN}/datasets/kdd12"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="liblinear62"

function func_prepare() {
	echo "Preparing benchmark start..."
    killall train
    killall perf
	echo 3 > /proc/sys/kernel/numa_balancing
    # 禁止Swap
    swapoff -a 
    # 清空cache的缓存
    echo 3 > /proc/sys/vm/drop_caches
    sleep 2
	DATE=$(date +%Y%m%d%H%M)
    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}
}

function func_collaction(){
    PID=$(pgrep -o train)
    echo "---------Collaction ${PID}------------"

    perf record -F 1 -o ${LOG_DIR}/perf.data -a -g & 
    perf_pid=$(pgrep -o -f "perf record")
    while kill -0 "${PID}" >/dev/null 2>&1
    do
        cat /proc/vmstat | grep pgmigrate_su >> ${LOG_DIR}/pgmig.txt
        numastat -m | grep -e Mem -e Dir -e PageTab -e Write -e FileP -e AnonP >> ${LOG_DIR}/numa_use.txt  
        sleep 5 
    done
    kill -SIGINT "$perf_pid"
}

function func_main() {
    TIME="/usr/bin/time"
    echo "Date: ${DATE}"

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/before_vmstat.log 
	cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 

    # 对于机器学习要让他可以输出到这里
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log &
    func_collaction

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
    sleep 120
    killall perf
}

################################ Main ##################################

for i in {1..3};
do
	VER="stab${i}"
	func_prepare
	func_main
done
