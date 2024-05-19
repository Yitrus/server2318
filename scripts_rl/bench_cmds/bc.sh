#!/bin/bash

BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs
BENCH_RUN="${BIN}/bc -f ${GRAPH_DIR}/urand.sg -i4 -n20"

export BENCH_RUN