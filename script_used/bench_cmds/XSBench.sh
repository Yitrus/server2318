#!/bin/bash

BIN=/home/xmu/playground/yi/workload/XSBench/openmp-threading
BENCH_RUN="${BIN}/XSBench -t 20 -g 130000 -p 30000000"
#BENCH_DRAM=""


#if [[ "x${NVM_RATIO}" == "x1:16" ]]; then
 #   BENCH_DRAM="3850MB"
#elif [[ "x${NVM_RATIO}" == "x1:8" ]]; then
 #   BENCH_DRAM="7200MB"
#elif [[ "x${NVM_RATIO}" == "x1:4" ]]; then
 #   BENCH_DRAM="13107MB"
#elif [[ "x${NVM_RATIO}" == "x1:2" ]]; then
 #   BENCH_DRAM="21800MB"
#elif [[ "x${NVM_RATIO}" == "x1:1" ]]; then
 #   BENCH_DRAM="32768MB"
#elif [[ "x${NVM_RATIO}" == "x1:32" ]]; then
 #   BENCH_DRAM="1986MB"
#elif [[ "x${NVM_RATIO}" == "x2:1" ]]; then
 #   BENCH_DRAM="43691MB"
#elif [[ "x${NVM_RATIO}" == "x4:1" ]]; then
 #   BENCH_DRAM="52429MB"
#fi


export BENCH_RUN
#export BENCH_DRAM
