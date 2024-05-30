#!/bin/bash

######## changes the below path complex.cfg
# numactl --membind=2 /home/ssd/yi/tools/masim//masim /home/ssd/yi/tools/masim/configs/default
BIN=/home/ssd/yi/tools/masim/

BENCH_RUN="${BIN}/masim ${BIN}/configs/default"

export BENCH_RUN
