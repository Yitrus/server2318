#!/bin/bash

BENCH_NAME="pr"
BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs

BENCH_RUN="${BIN}/pr -f ${GRAPH_DIR}/twitter.sg -i1000 -t1e-4 -n20"
