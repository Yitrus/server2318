#!/bin/bash

BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs
BENCH_RUN="${BIN}/cc -f ${GRAPH_DIR}/urand30.sg -n20"

export BENCH_RUN