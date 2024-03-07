#!/bin/bash

BENCHMARKS="gapbs-pr" 
#BENCHMARKS="gapbs-pr XSBench liblinear"

sudo dmesg -c 


for BENCH in ${BENCHMARKS};
do
    ./run_bench.sh -B ${BENCH} -V TPP-0.3-V3
done

# 以下是XSBench的配置数据——————————————————————————————————————————————
# memmap=20G!41G 1:1
# 0.9的DRAM 只完全使用0，2节点即可
# 0.8 memmap=4G!60G
# 0.7 memmap=10G!53G
# 但是仍然有明显波动，于是换一换workload试试—————————————————————————————

# pr试试
# 0.8 35G!28G
# 0.5 40G!10G 怎么又12G了
# 0.3 53G!9G 7G can use emmmm
