#!/bin/bash

TARGET=$1

while :
do
    numastat -m | grep -e Mem -e Dir -e PageTab -e Write -e FileP -e AnonP >> ${TARGET}/numa_use.txt 
    sleep 5s
done