#!/bin/bash

BENCH_NAME="ycsbload"

BIN=/home/ssd/yi/workloads/ycsb-0.15.0
BENCH_RUN="/home/ssd/yi/workloads/ycsb-0.15.0/bin/ycsb load memcached -s -P /home/ssd/yi/workloads/ycsb-0.15.0/workloads/workloada -p "memcached.hosts=127.0.0.1" -p "memcached.port=11211" -p recordcount=1000000000 -threads 112"


