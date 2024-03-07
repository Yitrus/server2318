#!/bin/bash
TPP_PATH=/home/xmu/playground/yi/res
RES_PATH=/home/xmu/playground/yi/results
WKL_PATH=/home/xmu/playground/yi/workloads
TOOL_PATH=/home/xmu/playground/yi/tools
DEF_PATH=/home/xmu/playground/yi/default_numa

pr1() {
    echo "pr1"
    numactl --cpunodebind=0 --membind=0,2 $WKL_PATH/gapbs/pr -f $WKL_PATH/gapbs/benchmark/graphs/twitter.sg -i100 -t1e-3 -n5 >> $RES_PATH/pr.out
}

pr3() {
    echo "pr3"
    numactl --cpunodebind=0 --membind=0,2 $WKL_PATH/gapbs/pr -f $WKL_PATH/gapbs/benchmark/graphs/twitter.sg -i100 -t1e-3 -n5 >> $TPP_PATH/pr.out &
    program_pid=$!
    echo "$program_pid" &
    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
            cat /proc/vmstat >> pr3.txt
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    break
        fi
    done	
}

pr0() {
    echo "pr0"
    numactl --cpunodebind=0 --membind=0,2 $WKL_PATH/gapbs/pr -f $WKL_PATH/gapbs/benchmark/graphs/twitter.sg -i100 -t1e-3 -n5 >> $DEF_PATH/pr.out
}


echo 10000 > /proc/sys/kernel/perf_event_max_sample_rate
damo record --numa_node 0 --ops paddr -r "4294967296-23622320127" --monitoring_nr_regions 1000 10000 -s 5000 -a 200000 -u 1000000 -o $DEF_PATH/pr.data &

echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 0 > /proc/sys/kernel/numa_balancing 

cat /proc/vmstat >> pr_begin.txt
pr0
echo '__________________________________________'

echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 1 > /proc/sys/kernel/numa_balancing 
cat /proc/vmstat >> pr0.txt
pr1
echo '__________________________________________'

echo 1 > /sys/kernel/mm/numa/demotion_enabled 
echo 3 > /proc/sys/kernel/numa_balancing 
cat /proc/vmstat >> pr1.txt
pr3






