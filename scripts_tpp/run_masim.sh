DIR=/home/ssd/yi/scripts_tpp
BIN=/home/ssd/yi/tools/masim/
BENCH_RUN="${BIN}/masim ${BIN}/configs/default" # complex.cfg default
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="masim" 

function func_prepare() {
    echo 3 > /proc/sys/vm/drop_caches

	DATE=$(date +%Y%m%d%H%M)

    mkdir -p ${DIR}/logs/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/logs/${BENCH_NAME}/${VER}
}

function func_main() {
    TIME="/usr/bin/time"
    echo "Date: ${DATE}"

    # cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/before_vmstat.log 
	# cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 

    # ${DIR}/mem.sh ${LOG_DIR} &
    ${TIME} -f "execution time %e (s)" \
    ${BENCH_RUN} 2>&1 | tee ${LOG_DIR}/output.log 

    # cat /proc/vmstat | grep -e thp -e pgmig >> ${LOG_DIR}/after_vmstat.log
	# cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log    

    # sudo killall mem.sh
    # dmesg -c > ${LOG_DIR}/dmesg.txt
}

################################ Main ##################################

# 测量2次看看稳定否
# for i in {1..2};
# do
	# VER="g-urand-${i}"
    VER="masim-3"
	func_prepare
	func_main
# done

