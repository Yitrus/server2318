#!/bin/bash
TPP_PATH=/home/xmu/playground/yi/res
RES_PATH=/home/xmu/playground/yi/results
WKL_PATH=/home/xmu/playground/yi/workloads
TOOL_PATH=/home/xmu/playground/yi/tools
DEF_PATH=/home/xmu/playground/yi/default_numa

xsb1() {
    echo "xsb1"
    numactl --membind=0,2 $WKL_PATH/XSBench/openmp-threading/XSBench -t 20 -g 130000 -p 30000000 >> $RES_PATH/xsb.out
}

xsb3() {
    echo "xsb3"
    numactl --membind=0,2 $WKL_PATH/XSBench/openmp-threading/XSBench -t 20 -g 130000 -p 30000000 >> $TPP_PATH/xsb.out &
    program_pid=$!
    echo "$program_pid" &
    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
            cat /proc/vmstat >> xsb3.txt
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    break
        fi
    done	
}

xsb0() {
    echo "xsb0"
    numactl --membind=0,2 $WKL_PATH/XSBench/openmp-threading/XSBench -t 20 -g 130000 -p 30000000 >> $DEF_PATH/xsb.out
}


echo 10000 > /proc/sys/kernel/perf_event_max_sample_rate
damo record --numa_node 0 --ops paddr -r "4294967296-50465865727" --monitoring_nr_regions 100 2000 -s 10000 -a 5000000 -u 1000000 -o $DEF_PATH/xsb.data &

echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 0 > /proc/sys/kernel/numa_balancing 

cat /proc/vmstat >> xsb_begin.txt
xsb0
echo '__________________________________________'

echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 1 > /proc/sys/kernel/numa_balancing 
cat /proc/vmstat >> xsb0.txt
xsb1
echo '__________________________________________'

echo 1 > /sys/kernel/mm/numa/demotion_enabled 
echo 3 > /proc/sys/kernel/numa_balancing 
cat /proc/vmstat >> xsb1.txt
xsb3






