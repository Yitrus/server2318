#!/bin/bash

######## changes the below path
# numactl --membind=2 /home/ssd/yi/tools/masim//masim /home/ssd/yi/tools/masim/configs/default
BIN=/home/ssd/yi/tools/masim/

BENCH_RUN="${BIN}/masim ${BIN}/configs/s4_wide2hot.cfg"

export BENCH_RUN
