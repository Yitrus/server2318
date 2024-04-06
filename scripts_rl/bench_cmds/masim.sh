#!/bin/bash

######## changes the below path
# numactl --membind=2 /home/xmu/Documents/yi/tools/masim//masim /home/xmu/Documents/yi/tools/masim/configs/default
BIN=/home/xmu/Documents/yi/tools/masim/

BENCH_RUN="${BIN}/masim ${BIN}/configs/default"

export BENCH_RUN
