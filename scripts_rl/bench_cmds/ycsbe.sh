#!/bin/bash

BIN=/home/ssd/yi/workloads/ycsb-0.15.0
BENCH_RUN="${BIN}/bin/ycsb run memcached -s -P ${BIN}/workloads/workloade -p "memcached.hosts=127.0.0.1" -p "memcached.port=11211" -p recordcount=1000000000 -p operationcount=125000000 -threads 112"

export BENCH_RUN