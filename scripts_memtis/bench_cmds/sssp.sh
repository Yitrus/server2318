#!/bin/bash

BIN=/home/ssd/yi/workloads/gapbs
GRAPH_DIR=/home/ssd/yi/workloads/gapbs/benchmark/graphs
BENCH_RUN="${BIN}/sssp -f ${GRAPH_DIR}/web.wsg"

export BENCH_RUN