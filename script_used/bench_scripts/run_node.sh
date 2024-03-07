#!/bin/bash

if [ -z $NTHREADS ]; then
    NTHREADS=$(grep -c processor /proc/cpuinfo)
fi
export NTHREADS
NCPU_NODES=$(cat /sys/devices/system/node/has_cpu | awk -F '-' '{print $NF+1}')
NMEM_NODES=$(cat /sys/devices/system/node/has_memory | awk -F '-' '{print $NF+1}')
MEM_NODES=($(ls /sys/devices/system/node | grep node | awk -F 'node' '{print $NF}'))

CGROUP_NAME="htmm"
###### update DIR!
DIR=/home/xmu/Documents/yi/scripts_memtis
NODE0=24GB


CONFIG_PERF=off
CONFIG_NS=off
CONFIG_NW=off
CONFIG_CXL_MODE=off
STATIC_DRAM=""
DATE=""
VER=""

function func_cache_flush() {
	killall bfs
    killall perf
	swapoff -a 
    echo 3 > /proc/sys/vm/drop_caches
    free
    return
}

function func_collaction(){
    sleep 3
    PID=$(pgrep -o train)
    echo "---------Collaction ${PID}------------"

    perf record -F 1 -o ${LOG_DIR}/perf.data -a -g & 
    perf_pid=$(pgrep -o -f "perf record")
    while kill -0 "${PID}" >/dev/null 2>&1
    do
        sleep 10
    done
	kill -SIGINT "$perf_pid"
}


function func_memtis_setting() {
    echo 199 | tee /sys/kernel/mm/htmm/htmm_sample_period
    echo 100007 | tee /sys/kernel/mm/htmm/htmm_inst_sample_period
    echo 1 | tee /sys/kernel/mm/htmm/htmm_thres_hot
    echo 2 | tee /sys/kernel/mm/htmm/htmm_split_period
    echo 100000 | tee /sys/kernel/mm/htmm/htmm_adaptation_period
    echo 2000000 | tee /sys/kernel/mm/htmm/htmm_cooling_period
    echo 2 | tee /sys/kernel/mm/htmm/htmm_mode
    echo 500 | tee /sys/kernel/mm/htmm/htmm_demotion_period_in_ms
    echo 500 | tee /sys/kernel/mm/htmm/htmm_promotion_period_in_ms
    echo 4 | tee /sys/kernel/mm/htmm/htmm_gamma
    ###  cpu cap (per mille) for ksampled
    echo 30 | tee /sys/kernel/mm/htmm/ksampled_soft_cpu_quota

    if [[ "x${CONFIG_NS}" == "xoff" ]]; then
	echo 1 | tee /sys/kernel/mm/htmm/htmm_thres_split
    else
	echo 0 | tee /sys/kernel/mm/htmm/htmm_thres_split
    fi

    if [[ "x${CONFIG_NW}" == "xoff" ]]; then
	echo 0 | tee /sys/kernel/mm/htmm/htmm_nowarm
    else
	echo 1 | tee /sys/kernel/mm/htmm/htmm_nowarm
    fi

    if [[ "x${CONFIG_CXL_MODE}" == "xon" ]]; then
	${DIR}/bench_scripts/set_uncore_freq.sh on
	echo "enabled" | tee /sys/kernel/mm/htmm/htmm_cxl_mode
    else
	${DIR}/bench_scripts/set_uncore_freq.sh off
	echo "disabled" | tee /sys/kernel/mm/htmm/htmm_cxl_mode
    fi

	# echo "never" | tee /sys/kernel/mm/transparent_hugepage/enabled
    echo "always" | tee /sys/kernel/mm/transparent_hugepage/enabled
	# 它控制内核是否应该积极使用内存压缩来提供更多的大页面可用
    echo "always" | tee /sys/kernel/mm/transparent_hugepage/defrag
}

function func_prepare() {
    echo "Preparing benchmark start..."

	sudo sysctl kernel.perf_event_max_sample_rate=100000

	# disable automatic numa balancing
	sudo echo 0 > /proc/sys/kernel/numa_balancing
	# set configs
	func_memtis_setting
	
	DATE=$(date +%Y%m%d%H%M)

	export BENCH_NAME

	if [[ -e ${DIR}/bench_cmds/${BENCH_NAME}.sh ]]; then
	    source ${DIR}/bench_cmds/${BENCH_NAME}.sh
	else
	    echo "ERROR: ${BENCH_NAME}.sh does not exist."
	    exit -1
	fi
}

function func_main() {
    ${DIR}/bin/kill_ksampled
    TIME="/usr/bin/time"

    if [[ "x${CONFIG_PERF}" == "xon" ]]; then
	PERF="./perf stat -e dtlb_store_misses.walk_pending,dtlb_load_misses.walk_pending,dTLB-store-misses,cycle_activity.stalls_total"
    else
	PERF=""
    fi
    
    # use 20 threads 
    PINNING="taskset -c 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38"

    echo "-----------------------"
    # echo "NVM RATIO: ${NVM_RATIO}"
    echo "${DATE}"
    echo "-----------------------"

    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}

    # set memcg for htmm
    sudo ${DIR}/bench_scripts/set_htmm_memcg.sh htmm remove
    sudo ${DIR}/bench_scripts/set_htmm_memcg.sh htmm $$ enable

    sudo ${DIR}/bench_scripts/set_mem_size.sh htmm 0 ${NODE0}

    echo "set cgroup sleep 30 sec"
    sleep 30

    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/before_vmstat.log 
	cat /proc/meminfo >> ${LOG_DIR}/before_vmstat.log 
    # flush cache
    func_cache_flush
    sleep 2

	# 在这里加上对 node 0 的限制 numactl --membind=0,2
    ${DIR}/bench_scripts/memory_stat.sh ${LOG_DIR} &
	${TIME} -f "execution time %e (s)" \
	    ${PINNING} ${DIR}/bin/launch_bench ${BENCH_RUN} 2>&1 \
	    | tee ${LOG_DIR}/output.log 
    # func_collaction

    sudo killall -9 memory_stat.sh
    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/after_vmstat.log
	cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log
    sleep 120

    sudo dmesg -c > ${LOG_DIR}/dmesg.txt
    # disable htmm
    sudo ${DIR}/bench_scripts/set_htmm_memcg.sh htmm $$ disable
}

function func_usage() {
    echo
    echo -e "Usage: $0 [-b benchmark name] [-s socket_mode] [-w GB] ..."
    echo
    echo "  -B,   --benchmark   [arg]    benchmark name to run. e.g., graph500, Liblinear, etc"
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
