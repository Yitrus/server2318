#!/bin/bash

BENCHMARKS="masim_s3" 
DRAM_SIZE="16GB"
# DRAM_SIZE="16GB"
dmesg -c 

for BENCH in ${BENCHMARKS};
do
    for NR in ${DRAM_SIZE};
    do
        # for i in {1..2};
        # do
	    # ./bench_scripts/run_balance.sh -B ${BENCH} -V "xx_${i}"
        ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V "4" # -${i}
        # rm kdd12*
        # done
    done
done

# for BENCH in ${BENCHMARKS};
# do
#     for NR in ${DRAM_SIZE};
#     do
#         ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V "${NR}basic"
#     done
# done