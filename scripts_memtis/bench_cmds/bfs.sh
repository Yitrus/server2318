#!/bin/bash

######## changes the below path
BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs

BENCH_RUN="${BIN}/bfs -f ${GRAPH_DIR}/kron.sg -n 20"

export BENCH_RUN

