# 12.3G 2:1 1:1 1:2 按照GB设置每次DRAM 8G 6G 4G
# 实际情况，由于空间预留，每次需要多给10个G

DIR=/home/ssd/yi/scripts_tired08
BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs/
BENCH_RUN="numactl --membind=0,2 ${BIN}/pr -f ${GRAPH_DIR}/twitter.sg -i1000 -t1e-4 -n20"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="pr" 

function func_prepare() {
    killall ${BENCH_NAME}

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

function func_main() {
    TIME="/usr/bin/time"
    echo "Date: ${DATE}"

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/before_vmstat.log 
	cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 

    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log 

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    dmesg -c > ${LOG_DIR}/dmesg.txt
}

################################ Main ##################################

# 测量2次看看稳定否
for i in {1..2};
do
	VER="G-${i}"
	func_prepare
	func_main
done

