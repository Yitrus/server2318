#!/bin/bash

BENCH_NAME="liblinear"

BIN=/home/ssd/yi/workload/liblinear-multicore-2.47
BENCH_RUN="${BIN}/train -s 6 -m 20 ${BIN}/datasets/kdd12"