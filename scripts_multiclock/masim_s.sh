DIR=/home/ssd/yi/scripts_multiclock
BIN=/home/ssd/yi/tools/masim

BENCH_RUN="numactl --cpunodebind=0 ${BIN}/masim ${BIN}/configs/s4.cfg"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="masim_s4" 

function func_prepare() {
    echo 3 > /proc/sys/vm/drop_caches

    sysctl -w kernel.perf_event_max_sample_rate=100000

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
# for i in {1..2};
# do
	# VER="static-kron-${i}"
    VER="4"
	func_prepare
	func_main
# done

