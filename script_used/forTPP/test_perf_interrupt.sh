#!/bin/bash

BIN=/home/xmu/Documents/yi/workload/XSBench/openmp-threading
BENCH_RUN="numactl -N 0 --membind=0,2 ${BIN}/XSBench -t 20 -g 13000 -p 3000000"
PID=""

function func_collaction(){
    PID=$(pgrep -o XSBench)
    echo "---------Collaction ${PID}------------"
    perf record -F 10 -o ./test.data -a -g &
    perf_pid=$(pgrep -o -f "perf record")
    while kill -0 "${PID}" >/dev/null 2>&1
    do
        echo "perf_pid: $perf_pid"
        sleep 5 
    done
    kill -SIGINT "$perf_pid"
}

${BENCH_RUN} > ./test.log &
func_collaction