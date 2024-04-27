#!/bin/bash

# 这个workload大小2:1, 1:1, 1:2, 45G,34G,23G
# 实际情况，由于空间预留，每次需要多给11个G

DIR=/home/xmu/Documents/yi/scripts_tired08
BIN=/home/xmu/Documents/yi/workload/liblinear-multicore-2.47
BENCH_RUN="numactl --membind=0,2 ${BIN}/train -s 6 -m 20 ${BIN}/datasets/kdd12"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="liblinear" 

function func_prepare() {
    killall train
    # 内核要开启的
	echo 1 > /sys/kernel/mm/numa/demotion_enabled
    ## enable numa balancing for promotion
    echo 2 > /proc/sys/kernel/numa_balancing
    echo 30 > /proc/sys/kernel/numa_balancing_rate_limit_mbps
    ## enable early wakeup
    echo 1 > /proc/sys/kernel/numa_balancing_wake_up_kswapd_early
    ## enable decreasing hot threshold if the pages just demoted are hot
    echo 1 > /proc/sys/kernel/numa_balancing_scan_demoted
    echo 16 > /proc/sys/kernel/numa_balancing_demoted_threshold
    
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

    # 对于机器学习要让他可以输出到这里
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log 
    # &
    # func_collaction

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
    # sleep 120
    # killall perf
}

################################ Main ##################################

# 测量2次看看稳定否
for i in {1..2};
do
	VER="45G-${i}"
	func_prepare
	func_main
done
