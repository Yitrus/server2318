#!/bin/bash

#BENCHMARKS="XSBench graph500 gapbs-pr liblinear silo btree"
BENCHMARKS="XSBench"
sudo dmesg -c

# enable THP
sudo echo "always" | tee /sys/kernel/mm/transparent_hugepage/enabled
sudo echo "always" | tee /sys/kernel/mm/transparent_hugepage/defrag

for BENCH in ${BENCHMARKS};
do
    export GOMP_CPU_AFFINITY=0-19
    
    if [[ -e ./bench_cmds/${BENCH}.sh ]]; then
	source ./bench_cmds/${BENCH}.sh
    else
	echo "ERROR: ${BENCH}.sh does not exist."
	continue
    fi

    mkdir -p results/${BENCH}/all-dram/static
    LOG_DIR=results/${BENCH}/all-dram/static

    free;sync;echo 3 > /proc/sys/vm/drop_caches;free;

    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/before_vmstat.log 

    #${DIR}/scripts/memory_stat.sh ${LOG_DIR} &
    if [[ "x${BENCH}" =~ "xspeccpu" ]]; then
	/usr/bin/time -f "execution time %e (s)" \
	    taskset -c 0-19 numactl --membind=0,1 ${BENCH_RUN} < ${BENCH_ARG} 2>&1 \
	    | tee ${LOG_DIR}/output.log
    else
	/usr/bin/time -f "execution time %e (s)" \
	    numactl -N 0 --membind=0,1 ${BENCH_RUN} 2>&1 \
	    | tee ${LOG_DIR}/output.log
    fi

    #sudo killall -9 memory_stat.sh
    cat /proc/vmstat | grep -e thp -e htmm -e pgmig > ${LOG_DIR}/after_vmstat.log

done
