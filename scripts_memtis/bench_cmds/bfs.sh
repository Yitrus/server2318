#!/bin/bash

######## changes the below path
BIN=/home/xmu/Documents/yi/workload/gapbs
GRAPH_DIR=/home/xmu/Documents/yi/workload/gapbs/benchmark

BENCH_RUN="${BIN}/bfs -f ${GRAPH_DIR}/kron.sg -n 20"

export BENCH_RUN

