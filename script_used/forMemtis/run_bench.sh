#!/bin/bash

DIR=/home/xmu/playground/yi/script/memtis/memtis-userspace

STATIC_DRAM=""
DATE=""
VER=""


function func_setting() {
    echo "never" | tee /sys/kernel/mm/transparent_hugepage/enabled
    # echo "always" | tee /sys/kernel/mm/transparent_hugepage/enabled
	# 它控制内核是否应该积极使用内存压缩来提供更多的大页面可用
    # echo "always" | tee /sys/kernel/mm/transparent_hugepage/defrag
}

function func_prepare() {
    echo "Preparing benchmark start..."

	# sudo sysctl kernel.perf_event_max_sample_rate=100000

	# disable automatic numa balancing
	sudo echo 3 > /proc/sys/kernel/numa_balancing
	# set configs
	func_setting
	
	DATE=$(date +%Y%m%d%H%M)

	export BENCH_NAME

	if [[ -e ${DIR}/bench_cmds/${BENCH_NAME}.sh ]]; then
	    source ${DIR}/bench_cmds/${BENCH_NAME}.sh
	else
	    echo "ERROR: ${DIR}/bench_cmds/${BENCH_NAME}.sh does not exist."
	    exit -1
	fi
}

function func_main() {
    TIME="/usr/bin/time"

    echo "-----------------------"
    echo "${DATE}"
    echo "-----------------------"

    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}

    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/before_vmstat.log 
    cat /proc/meminfo >>  ${LOG_DIR}/before_vmstat.log 
    sleep 2

    # 在这里加上对 node 0 的限制 
    ${DIR}/scripts/memory_stat.sh ${LOG_DIR} &
    if [[ "x${BENCH_NAME}" =~ "xsilo" ]]; then
	${TIME} -f "execution time %e (s)" \
	    numactl -N 0 --membind=0,2 ${BENCH_RUN} 2>&1 \
	    | tee ${LOG_DIR}/output.log
    elif [[ "x${BENCH_NAME}" =~ "xspeccpu" ]]; then
	${TIME} -f "execution time %e (s)" \
	    numactl -N 0 --membind=0,2 ${BENCH_RUN} < ${BENCH_ARG} 2>&1 \
	    | tee ${LOG_DIR}/output.log
    else 
	${TIME} -f "execution time %e (s)" \
	    numactl -N 0 --membind=0,2 ${BENCH_RUN} 2>&1 \
	    | tee ${LOG_DIR}/output.log
    fi

    sudo killall -9 memory_stat.sh
    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/after_vmstat.log
    cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log
    sleep 2

    if [[ "x${BENCH_NAME}" == "xbtree" ]]; then
	cat ${LOG_DIR}/output.log | grep Throughput \
	    | awk ' NR%20==0 { print sum ; sum = 0 ; next} { sum+=$3 }' \
	    > ${LOG_DIR}/throughput.out
    elif [[ "x${BENCH_NAME}" =~ "xsilo" ]]; then
	cat ${LOG_DIR}/output.log | grep -e '0 throughput' -e '5 throughput' \
	    | awk ' { print $4 }' > ${LOG_DIR}/throughput.out
    fi

    sudo dmesg -c > ${LOG_DIR}/dmesg.txt
}

function func_usage() {
    echo
    echo -e "Usage: $0 [-b benchmark name] [-s socket_mode] [-w GB] ..."
    echo
    echo "  -B,   --benchmark   [arg]    benchmark name to run. e.g., graph500, Liblinear, etc"
    #echo "  -R,   --ratio       [arg]    fast tier size vs. capacity tier size: \"1:16\", \"1:8\", or \"1:2\""
    echo "  -D,   --dram        [arg]    static dram size [MB or GB]; only available when -R is set to \"static\""
    echo "  -V,   --version     [arg]    a version name for results"
    echo "  -NS,  --nosplit              disable skewness-aware page size determination"
    echo "  -NW,  --nowarm               disable the warm set"
    echo "        --cxl                  enable cxl mode [default: disabled]"
    echo "  -?,   --help"
    echo "        --usage"
    echo
}


################################ Main ##################################

if [ "$#" == 0 ]; then
    echo "Error: no arguments"
    func_usage
    exit -1
fi

# get options:
while (( "$#" )); do
    case "$1" in
	-B|--benchmark)
	    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
		BENCH_NAME=( "$2" )
		shift 2
	    else
		echo "Error: Argument for $1 is missing" >&2
		func_usage
		exit -1
	    fi
	    ;;
	-V|--version)
	    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
		VER=( "$2" )
		shift 2
	    else
		func_usage
		exit -1
	    fi
	    ;;
	-P|--perf)
	    CONFIG_PERF=on
	    shift 1
	    ;;
	#-R|--ratio)
	    #if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
		#NVM_RATIO="$2"
		#shift 2
	    #else
		#func_usage
		#exit -1
	    #fi
	    #;;
	-D|--dram)
	    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
		STATIC_DRAM="$2"
		shift 2
	    else
		func_usage
		exit -1
	    fi
	    ;;
	-NS|--nosplit)
	    CONFIG_NS=on
	    shift 1
	    ;;
	-NW|--nowarm)
	    CONFIG_NW=on
	    shift 1
	    ;;
	--cxl)
	    CONFIG_CXL_MODE=on
	    shift 1
	    ;;
	-H|-?|-h|--help|--usage)
	    func_usage
	    exit
	    ;;
	*)
	    echo "Error: Invalid option $1"
	    func_usage
	    exit -1
	    ;;
    esac
done

if [ -z "${BENCH_NAME}" ]; then
    echo "Benchmark name must be specified"
    func_usage
    exit -1
fi

func_prepare
func_main
