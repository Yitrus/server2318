DIR=/home/ssd/yi/scripts_at08
BIN=/home/ssd/yi/tools/masim

NR=""
BENCH_RUN=""
DATE=""
VER=""
PID=""
LOG_DIR=""
BENCH_NAME="masim" 

function func_prepare() {
	#### default setting
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

    sysctl -w kernel.perf_event_max_sample_rate=100000

	DATE=$(date +%Y%m%d%H%M)

    # make directory for results
    mkdir -p ${DIR}/results/${BENCH_NAME}/${VER}${NR}
    LOG_DIR=${DIR}/results/${BENCH_NAME}/${VER}${NR}
	BENCH_RUN="numactl --cpunodebind=0 ${BIN}/masim ${BIN}/configs/s${NR}.cfg"
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
while (( "$#" )); do
    case "$1" in
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
		NR="$2"
		shift 2
	    else
		func_usage
		exit -1
	    fi
	    ;;
	*)
	    echo "Error: Invalid option $1"
	    func_usage
	    exit -1
	    ;;
    esac
done

func_prepare
func_main


