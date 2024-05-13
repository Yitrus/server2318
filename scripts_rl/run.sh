#!/bin/bash

BENCHMARKS="train"  # train
# DRAM_SIZE="5GB 14GB 31GB 40GB 47GB 55GB 34GB 23G"
DRAM_SIZE="23GB"
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
        ./bench_scripts/run_node.sh -B ${BENCH} -R ${NR} -V ${NR}-v40-huge-1
        killall run.py
        sleep 120
    done
done