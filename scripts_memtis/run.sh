#!/bin/bash

BENCHMARKS="masim" 
# DRAM_SIZE="5GB 14GB 31GB 40GB 47GB 55GB"
DRAM_SIZE="30GB"
dmesg -c 

for BENCH in ${BENCHMARKS};
do
    for NR in ${DRAM_SIZE};
    do
        for i in {1..2};
        do
	    # ./bench_scripts/run_balance.sh -B ${BENCH} -V "xx_${i}"
        ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V "less1G-${NR}-${i}"
        # rm kdd12*
        done
    done
done
