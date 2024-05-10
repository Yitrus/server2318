#!/bin/bash

# 这个workload大小2:1, 1:1, 1:2, 45G,34G,23G
# 实际情况，由于空间预留，每次需要多给11个G

DIR=/home/ssd/yi/scripts_tpp
BIN=/home/ssd/yi/workloads/liblinear-multicore-2.47
BENCH_RUN="numactl --membind=0,1,2 ${BIN}/train -s 6 -m 20 ${BIN}/datasets/kdd12"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="liblinear" 

function func_prepare() {
    killall train

    # 内核要开启的
    echo 1 > /sys/kernel/mm/numa/demotion_enabled
	echo 3 > /proc/sys/kernel/numa_balancing
    
    echo 3 > /proc/sys/vm/drop_caches

	DATE=$(date +%Y%m%d%H%M)

    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}
}

# 不用
# function func_collaction(){
#     PID=$(pgrep -o train)
#     echo "---------Collaction ${PID}------------"

#     perf record -F 1 -o ${LOG_DIR}/perf.data -a -g & 
#     perf_pid=$(pgrep -o -f "perf record")
#     while kill -0 "${PID}" >/dev/null 2>&1
#     do
#         cat /proc/vmstat | grep pgmigrate_su >> ${LOG_DIR}/pgmig.txt
#         numastat -m | grep -e Mem -e Dir -e PageTab -e Write -e FileP -e AnonP >> ${LOG_DIR}/numa_use.txt  
#         sleep 5 
#     done
#     kill -SIGINT "$perf_pid"
# }

function func_main() {
    TIME="/usr/bin/time"
    echo "Date: ${DATE}"

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/before_vmstat.log 
	cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 

    ${DIR}/mem.sh ${LOG_DIR} &
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log 
    # &
    # func_collaction

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
    sudo killall mem.sh
    # sleep 120
    # killall perf
}

################################ Main ##################################

# 测量2次看看稳定否
for i in {1..2};
do
	VER="cxl012-${i}"
	func_prepare
	func_main
done
