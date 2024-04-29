#!/bin/bash

BENCH_NAME="liblinear"

DIR=/home/xmu/Documents/yi/scripts_tired08
BIN=/home/xmu/Documents/yi/workload/liblinear-multicore-2.47
BENCH_RUN="${BIN}/train -s 6 -m 20 ${BIN}/datasets/kdd12"