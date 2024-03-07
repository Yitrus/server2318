#!/bin/bash
DAMON_PATH=/home/xmu/playground/yi/damo_test
WKL_PATH=/home/xmu/playground/yi/workloads
TOOL_PATH=/home/xmu/playground/yi/tools


prRun() {
    numactl --membind=0,2 $WKL_PATH/gapbs/pr -f $WKL_PATH/gapbs/benchmark/graphs/twitter.sg -i100 -t1e-3 -n5 >> $DAMON_PATH/pr.out &
    program_pid=$!
    echo "$program_pid" &
    
    while kill -0 "$program_pid" >/dev/null 2>&1
    do
        vmstat >> $DAMON_PATH/prSize.out
        sleep 5
    done
}

run_liner() {
    echo "liblinear"
    numactl --membind=0,2 $WKL_PATH/liblinear-multicore-2.47/train -s 6 -m 48 $WKL_PATH/liblinear-multicore-2.47/datasets/kdd12 >> $DAMON_PATH/liblinear.out &
    program_pid=$!
    echo "$program_pid" &
    while kill -0 "$program_pid" >/dev/null 2>&1
    do
        vmstat >> $DAMON_PATH/liblinerSize.out
        sleep 5
    done
}


run_XSB() {
    echo "XSBench"
    $WKL_PATH/XSBench/openmp-threading/XSBench -t 20 -g 130000 -p 30000000 >> $DAMON_PATH/XSB.out &
    program_pid=$!
    echo "$program_pid" &
   damo record --numa_node 0 --ops paddr -r "4294967296-23622320127" --monitoring_nr_regions 100 2000 -s 10000 -a 5000000 -u 1000000 -o $DAMON_PATH/XSB.data &
    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    sleep 1200
    	    break
    	else
    	    vmstat >> $DAMON_PATH/XSBSize.out
            sleep 60
        fi
    done	
    
}

echo 1 > /sys/kernel/mm/numa/demotion_enabled 
echo 3 > /proc/sys/kernel/numa_balancing 
run_XSB


