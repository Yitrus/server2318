#!/bin/bash

TARGET=$1

while :
do
    numastat -m | grep -e Mem -e Dir -e PageTab -e Write -e FileP -e AnonP >> ./numa_use.txt  # ${TARGET}
    sleep 120s
done