#!/bin/bash

BENCHMARKS="XSBench" 
DRAM_SIZE="14GB"
dmesg -c 

# for BENCH in ${BENCHMARKS};
# do
#     for NR in ${DRAM_SIZE};
#     do
#         for i in {1..2};
#         do
# 	    # ./bench_scripts/run_balance.sh -B ${BENCH} -V "xx_${i}"
#         ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V "${NR}-${i}"
#         # rm kdd12*
#         done
#     done
# done

for BENCH in ${BENCHMARKS};
do
    for NR in ${DRAM_SIZE};
    do
        ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V v41-3
        # killall run.py
        sleep 20
    done
done