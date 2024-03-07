#!/bin/bash
DEF_PATH=/home/xmu/playground/yi/default_numa
WKL_PATH=/home/xmu/playground/yi/workloads
TOOL_PATH=/home/xmu/playground/yi/tools

run_NPB() {
    program_name=$1
    size=$2
    echo "$program_name"
    numactl --membind=0,2 $TOOL_PATH/mpi/bin/mpirun -np $2 $WKL_PATH/NPB3.4.2/NPB3.4-MPI/bin/"${program_name}".D.x >> $DEF_PATH/$program_name.out &
    sleep 2
    program_pid=$(pgrep -o D.x)
    echo "$program_pid" &
    damo record --numa_node 0 --ops paddr -r "4294967296-23622320127" --monitoring_nr_regions 100 1000 -s 10000 -o $DEF_PATH/$program_name.data &

    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    sleep 600
            cat /proc/vmstat >> $program_name.txt
    	    break
        fi
    done	
}

run_pr() {
    echo "pr"
    numactl --membind=0,2 $WKL_PATH/gapbs/pr -f $WKL_PATH/gapbs/benchmark/graphs/twitter.sg -i100 -t1e-3 -n5 >> $DEF_PATH/pr.out &
    program_pid=$!
    echo "$program_pid" &
    damo record --numa_node 0 --ops paddr -r "4294967296-23622320127" --monitoring_nr_regions 100 1000 -s 5000 -o $DEF_PATH/pr.data &
    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    sleep 1200
            cat /proc/vmstat >> pr.txt
    	    break
        fi
    done	
}

run_G500() {
    numactl --cpunodebind=0 --membind=0,2 $WKL_PATH/graph500/src/graph500_reference_bfs_sssp 16 32 >> $DEF_PATH/g500.out &
    program_pid=$!
    echo "G500 16"
    
    damo record --numa_node 0 --ops paddr -r "4294967296-23622320127" --monitoring_nr_regions 100 1000 -s 1000 -o $DEF_PATH/g500.data &
    while true 
    do
        if ! kill -0 "$program_pid" >/dev/null 2>&1; then
    	    echo "collact data..."
    	    kill -SIGINT $(pgrep damo)
    	    sleep 300
            cat /proc/vmstat >> g500.txt
    	    break
        fi
    done	
    
}


echo 10000 > /proc/sys/kernel/perf_event_max_sample_rate
echo 0 > /sys/kernel/mm/numa/demotion_enabled 
echo 0 > /proc/sys/kernel/numa_balancing 
echo '__________________________________________'
cat /proc/vmstat >> begin2.txt

 run_pr
# run_NPB "ep" 36
# run_NPB "cg" 32
#run_G500
#run_NPB "mg" 32



