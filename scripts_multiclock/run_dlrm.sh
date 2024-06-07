DIR=/home/ssd/yi/scripts_multiclock
BIN=/home/ssd/yi/workloads/dlrm
BENCH_RUN="numactl --cpunodebind=0 ${BIN}/dlrm_s_criteo_kaggle.sh"
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="dlrm" 

function func_prepare() {

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
	# VER="g-urand-${i}"
    VER="1-2"
	func_prepare
	func_main
# done

