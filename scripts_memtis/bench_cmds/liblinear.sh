#!/bin/bash
BENCH_BIN=/home/xmu/Documents/yi/workload/liblinear-multicore-2.47

# anon footprint 79640MB
# file footprint 21581MB

BENCH_RUN="${BENCH_BIN}/train -s 6 -m 20 ${BENCH_BIN}/datasets/kdd12"


export BENCH_RUN
