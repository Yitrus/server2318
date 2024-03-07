#!/bin/bash
TPP_PATH=/home/xmu/playground/yi/res
RES_PATH=/home/xmu/playground/yi/results
WKL_PATH=/home/xmu/playground/yi/workloads
TOOL_PATH=/home/xmu/playground/yi/tools
DEF_PATH=/home/xmu/playground/yi/default_numa

xsb1() {
    echo "xsb1"
    numactl --membind=0,2 $WKL_PATH/XSBench/openmp-threading/XSBench -t 20 -g 130000 -p 30000000 >> $RES_PATH/xsb116.out
}

xsb3() {
    echo "xsb3"
    numactl --membind=0,2 $WKL_PATH/XSBench/openmp-threading/XSBench -t 20 -g 130000 -p 30000000 >> $TPP_PATH/xsb116.out &
    program_pid=$!
    echo "$program_pid" &
    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
            cat /proc/vmstat >> xsb3_116.txt
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    break
        fi
    done	
}


echo 10000 > /proc/sys/kernel/perf_event_max_sample_rate
damo record --numa_node 0 --ops paddr -r "4294967296-19327352831" --monitoring_nr_regions 100 2000 -s 10000 -a 5000000 -u 1000000 -o $DEF_PATH/xsb116.data &

cat /proc/vmstat >> xsb_begin_116.txt

echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 1 > /proc/sys/kernel/numa_balancing 

xsb1
echo '__________________________________________'

echo 1 > /sys/kernel/mm/numa/demotion_enabled 
echo 3 > /proc/sys/kernel/numa_balancing 
cat /proc/vmstat >> xsb1_116.txt
xsb3






