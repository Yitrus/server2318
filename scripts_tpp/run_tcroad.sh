DIR=/home/ssd/yi/scripts_tpp
BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs/
BENCH_RUN="numactl --membind=0,2 ${BIN}/tc -f ${GRAPH_DIR}/road.sg"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="tc" 

function func_prepare() {
    killall ${BENCH_NAME}
    # 内核要开启的
    echo 1 > /sys/kernel/mm/numa/demotion_enabled
	echo 3 > /proc/sys/kernel/numa_balancing

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

    ${DIR}/mem.sh ${LOG_DIR} &
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log 

    cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    sudo killall mem.sh
    dmesg -c > ${LOG_DIR}/dmesg.txt
}

################################ Main ##################################

# 测量2次看看稳定否
for i in {1..2};
do
	VER="road-cxl-${i}"
	func_prepare
	func_main
done

