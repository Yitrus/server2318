#!/bin/bash

# BENCHMARKS="XSBencch cc" 
BENCHMARKS="train" 
DRAM_SIZE="18637MB 31027MB 46592MB 62157MB"
# DRAM_SIZE="16GB"
dmesg -c 

# for BENCH in ${BENCHMARKS};
# do
#     for NR in ${DRAM_SIZE};
#     do
#         for i in {1..2};
#         do
# 	    # ./bench_scripts/run_balance.sh -B ${BENCH} -V "xx_${i}"
#         ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V ${NR}-v42-${i}
#         # rm kdd12*
#         done
#     done
# done

# killall -9 run_qt.py

for BENCH in ${BENCHMARKS};
do
    for NR in ${DRAM_SIZE};
    do
        ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V ${NR}-v42-bw
        killall -9 pcm-memory
        sleep 10
    done
done