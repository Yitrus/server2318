#!/bin/bash

######## changes the below path
BIN=/home/xmu/playground/yi/workloads/gapbs
GRAPH_DIR=/home/xmu/playground/yi/workloads/gapbs/benchmark/graphs/

BENCH_RUN="${BIN}/pr -f ${GRAPH_DIR}/twitter.sg -i1000 -t1e-4 -n20"
#BENCH_DRAM=""


# twitter.sg: ~12600MB 
# 现在发现是两倍，24200MB, 好像后面几个没有控制住

#if [[ "x${NVM_RATIO}" == "x1:32" ]]; then
 #   BENCH_DRAM="734MB"
#elif [[ "x${NVM_RATIO}" == "x1:16" ]]; then
 #   BENCH_DRAM="1424MB"
#elif [[ "x${NVM_RATIO}" == "x1:8" ]]; then
  #  BENCH_DRAM="2690MB"
#elif [[ "x${NVM_RATIO}" == "x1:4" ]]; then
 #   BENCH_DRAM="4842MB"
#elif [[ "x${NVM_RATIO}" == "x1:2" ]]; then
 #   BENCH_DRAM="8070MB"
#elif [[ "x${NVM_RATIO}" == "x1:1" ]]; then
    #BENCH_DRAM="12105MB"
#elif [[ "x${NVM_RATIO}" == "x2:1" ]]; then
    #BENCH_DRAM="16133MB"
#elif [[ "x${NVM_RATIO}" == "x4:1" ]]; then
    #BENCH_DRAM="19360MB"
# elif [[ "x${NVM_RATIO}" == "x8:1" ]]; then
#     BENCH_DRAM="21511MB"
#fi


export BENCH_RUN
#export BENCH_DRAM
