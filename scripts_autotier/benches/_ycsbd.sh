#!/bin/bash
BENCH_BIN=/home/ssd/yi/workloads/ycsb-0.15.0

MAX_THREADS=$(grep -c processor /proc/cpuinfo)
BENCH_RUN=""

#export OMP_DYNAMIC=FALSE
#export OMP_PROC_BIND=true
#export OMP_SCHEDULE=static
export OMP_DISPLAY_ENV=VERBOSE
export OMP_DISPLAY_AFFINITY=TRUE
export OMP_NUM_THREADS=$NTHREADS

if [[ $CONFIG_PINNED == "yes" ]]; then
	export KMP_AFFINITY="compact"
elif [[ $NTHREADS -eq $MAX_THREADS ]]; then
	export KMP_AFFINITY="proclist=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31],explicit" #,verbose
else
	export KMP_AFFINITY="compact,verbose"
	BENCH_RUN+="taskset -c 8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 "
fi

# case ${BENCH_SIZE} in
#     "kdd12")
        BENCH_RUN+="${BENCH_BIN}/bin/ycsb run memcached -s -P ${BENCH_BIN}/workloads/workloadd -p "memcached.hosts=127.0.0.1" -p "memcached.port=11211" -p recordcount=1000000000 -p operationcount=125000000 -threads 112"
    #     ;;
    # *)
# 	echo "ERROR: Retry with available SIZE. refer to benches/_liblinear.sh"
#         echo "${BENCH_NAME}: {kdd12}"

#         exit 1
# esac

export BENCH_RUN