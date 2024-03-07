#!/bin/bash
TPP_PATH=/home/xmu/playground/yi/res
RES_PATH=/home/xmu/playground/yi/results
WKL_PATH=/home/xmu/playground/yi/workloads
TOOL_PATH=/home/xmu/playground/yi/tools
DEF_PATH=/home/xmu/playground/yi/default_numa

liner0() {
    echo "liblinear0"
    numactl --membind=0,2 $WKL_PATH/liblinear-multicore-2.47/train -s 6 -m 20 $WKL_PATH/liblinear-multicore-2.47/datasets/kdd12 >> $DEF_PATH/liblinear.out 
}

liner1() {
    echo "liblinear1"
    numactl --membind=0,2 $WKL_PATH/liblinear-multicore-2.47/train -s 6 -m 20 $WKL_PATH/liblinear-multicore-2.47/datasets/kdd12 >> $RES_PATH/liblinear.out 
}

liner3() {
    echo "liblinear3"
    numactl --membind=0,2 $WKL_PATH/liblinear-multicore-2.47/train -s 6 -m 20 $WKL_PATH/liblinear-multicore-2.47/datasets/kdd12 >> $TPP_PATH/liblinear.out &
    program_pid=$!
    echo "$program_pid" &
    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
            cat /proc/vmstat >> line3.txt
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    break
        fi
        sleep 60
    done	
}


echo 10000 > /proc/sys/kernel/perf_event_max_sample_rate

damo record --numa_node 0 --ops paddr -r "4294967296-23622320127" --monitoring_nr_regions 125 5000 -s 200000 -a 1000000 -u 10000000 -o $DEF_PATH/liner.data &
echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 0 > /proc/sys/kernel/numa_balancing 

cat /proc/vmstat >> lin_begin.txt
liner0
echo '__________________________________________'

echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 1 > /proc/sys/kernel/numa_balancing 
cat /proc/vmstat >> line0.txt
liner1
echo '__________________________________________'

echo 1 > /sys/kernel/mm/numa/demotion_enabled 
echo 3 > /proc/sys/kernel/numa_balancing 
cat /proc/vmstat >> line1.txt
liner3


