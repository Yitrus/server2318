#!/bin/bash

TARGET=$1
NAME=$2

sleep 10
# echo "${NAME}"
PID=$(pgrep -o ${NAME})
# pgrep -f ${NAME} top
# echo "---------Collaction ${PID}------------"
# 这个时间段怎么控制？
# perf script record --data --phys-data --pid=${PID} -F 1 -e mem-loads,mem-stores -o ${TARGET}/perf.data &
# 20s输出一次？
perf stat -e cpu-cycles,instructions -I 20000 -a --pid=${PID} -o ${TARGET}/sample.txt 
# 1s 1次用于画火焰图来着
# perf record -F 1 -o ${LOG_DIR}/cpu.data -a -g --pid=${PID} &

# perf_pid=$(pgrep -o -f "perf record")
# while kill -0 "${PID}" >/dev/null 2>&1
# do
#     sleep 10
# done
# kill -SIGINT "$perf_pid"