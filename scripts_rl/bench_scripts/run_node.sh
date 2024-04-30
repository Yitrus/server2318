#!/bin/bash

CGROUP_NAME="htmm"
###### update DIR!
DIR=/home/xmu/Documents/yi/scripts_rl

TOP_NAME=""
CONFIG_PERF=off
CONFIG_CXL_MODE=off
STATIC_DRAM=""
DATE=""
VER=""

function func_memtis_setting() {
    echo 2 | tee /sys/kernel/mm/htmm/htmm_mode
    echo 4 | tee /sys/kernel/mm/htmm/htmm_gamma
    ##  cpu cap (per mille) for ksampled 这个内核中已经默认写了，被我取消了
    # echo 30 | tee /sys/kernel/mm/htmm/ksampled_soft_cpu_quota

	echo "--------set htmm mode and gamma--------"

    if [[ "x${CONFIG_CXL_MODE}" == "xon" ]]; then
	${DIR}/bench_scripts/set_uncore_freq.sh on
	echo "enabled" | tee /sys/kernel/mm/htmm/htmm_cxl_mode
    else
	${DIR}/bench_scripts/set_uncore_freq.sh off
	echo "disabled" | tee /sys/kernel/mm/htmm/htmm_cxl_mode
    fi

	echo "never" | tee /sys/kernel/mm/transparent_hugepage/enabled
    # echo "always" | tee /sys/kernel/mm/transparent_hugepage/enabled
	# 它控制内核是否应该积极使用内存压缩来提供更多的大页面可用
    # echo "always" | tee /sys/kernel/mm/transparent_hugepage/defrag

	echo "--------page size and cxl mode--------"
}

function func_prepare() {
	echo "--------func prepare--------"
	sysctl kernel.perf_event_max_sample_rate=100000
    # modprobe msr #pcm用的
	swapoff -a 
	# echo "--------clean caches--------"
    # echo 3 > /proc/sys/vm/drop_caches
	echo "--------free message--------"
    free

	# disable automatic numa balancing
	echo 0 > /proc/sys/kernel/numa_balancing
	# set configs
	echo "--------func setting--------"
	func_memtis_setting
	
	DATE=$(date +%Y%m%d%H%M)

	export BENCH_NAME
    export DRAM_SIZE

	if [[ -e ${DIR}/bench_cmds/${BENCH_NAME}.sh ]]; then
	    source ${DIR}/bench_cmds/${BENCH_NAME}.sh
	else
	    echo "ERROR: ${BENCH_NAME}.sh does not exist."
	    exit -1
	fi

	echo "--------get the bench cmd--------"
}

function cleanup(){
    dmesg -c > ${LOG_DIR}/dmesg.txt
	swapon -a
    # disable htmm
	${DIR}/bin/kill_ksampled
    ${DIR}/bench_scripts/set_htmm_memcg.sh htmm $$ disable
}

function func_main() {
    TIME="/usr/bin/time"

    echo "${DATE}"

    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}

    # set memcg for htmm
	echo "--------remove htmm/--------"
    ${DIR}/bench_scripts/set_htmm_memcg.sh htmm remove
	echo "--------enable htmm--------"
    ${DIR}/bench_scripts/set_htmm_memcg.sh htmm $$ enable
	# 迁移线程就启动了
	echo "--------set node size--------"
    ${DIR}/bench_scripts/set_mem_size.sh htmm 1 ${DRAM_SIZE}
	${DIR}/bench_scripts/set_mem_size.sh htmm 0 ${DRAM_SIZE}

    # ${DIR}/bench_scripts/memory_stat.sh ${LOG_DIR} 
    
    # for i in {1..20};
    # do
        cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/before_vmstat.log 
	    cat /proc/meminfo >> ${LOG_DIR}/before_vmstat.log 

		echo "--------after read run launch_bench--------"

        ${TIME} -f "execution time %e (s)" \
         ${DIR}/bin/launch_bench ${BENCH_RUN} 2>&1 \
            | tee ${LOG_DIR}/output${i}.log 

        cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/after_vmstat.log
	    cat /proc/meminfo >>  ${LOG_DIR}/after_vmstat.log
    # done 
        # ${DIR}/bench_scripts/perf_all.sh ${LOG_DIR} ${TOP_NAME}
   
    # wait $(pgrep -o ${TOP_NAME})
    cleanup
}

function func_usage() {
    echo
    echo -e "Usage: $0 [-b benchmark name] [-s socket_mode] [-w GB] ..."
    echo
    echo "  -B,   --benchmark   [arg]    benchmark name to run. e.g., graph500, Liblinear, etc"
    echo "  -V,   --version     [arg]    a version name for results"
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
        TOP_NAME=("$2")
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
    -R|--ratio)
	    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
		DRAM_SIZE="$2"
		shift 2
	    else
		func_usage
		exit -1
	    fi
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
