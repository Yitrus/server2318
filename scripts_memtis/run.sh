#!/bin/bash

BENCHMARKS="ycsbd ycsbe" 
# DRAM_SIZE="14746MB ycsba ycsbb ycsbc ycsbf "
DRAM_SIZE="2662MB"
dmesg -c 

for BENCH in ${BENCHMARKS};
do
    for NR in ${DRAM_SIZE};
    do
        # for i in {1..2};
        # do
	    # ./bench_scripts/run_balance.sh -B ${BENCH} -V "xx_${i}"
        ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V ${NR}-v42-2 # -${i}
        # killall -9 pcm-memory
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