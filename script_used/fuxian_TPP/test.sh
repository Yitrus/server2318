#!/bin/bash

run_NPB() {
    program_name=$1
    size=$2
    echo "$program_name"
    mpirun -np $2 /home/xmu/playground/yi/workloads/NPB3.4.2/NPB3.4-MPI/bin/"${program_name}".D.x >> /home/xmu/playground/yi/results/$program_name.out &
    #program_pid=$!
    sleep 2
    program_pid=$(pgrep -o D.x)
    echo "$program_pid"

    while kill -0 "$program_pid" >/dev/null 2>&1
    do
        vmstat >> /home/xmu/playground/yi/results/$program_name.vm.out
        iostat -xz >> /home/xmu/playground/yi/results/$program_name.io.out
        sleep 5
    done
}

run_G500_1() {
    /home/xmu/playground/yi/workloads/graph500/src/graph500_reference_bfs_sssp 32 16 >> /home/xmu/playground/yi/results/g5001.out&
    program_pid=$!
    echo "G500 32"
    
    while kill -0 "$program_pid" >/dev/null 2>&1
    do
        vmstat >> /home/xmu/playground/yi/results/g5001.vm.out
        iostat -xz >> /home/xmu/playground/yi/results/g5001.io.out
        sleep 10
    done
}

run_G500_2() {
    /home/xmu/playground/yi/workloads/graph500/src/graph500_reference_bfs_sssp 16 16 >> /home/xmu/playground/yi/results/g500.out&
    program_pid=$!
    echo "G500 16"
    
    while kill -0 "$program_pid" >/dev/null 2>&1
    do
        vmstat >> /home/xmu/playground/yi/results/g500.vm.out
        iostat -xz >> /home/xmu/playground/yi/results/g500.io.out
        sleep 5
    done
}

run_load() {
    /home/xmu/playground/yi/workloads/ycsb-0.15.0/bin/ycsb load memcached -s -P /home/xmu/playground/yi/workloads/ycsb-0.15.0/workloads/workloada -p memcached.hosts=127.0.0.1 -p memcached.port=11211 -p recordcount=1000000000 -threads 32
    echo "load"
}


run_ycsb() {
    program_name=$1
    echo $1
    /home/xmu/playground/yi/workloads/ycsb-0.15.0/bin/ycsb run memcached -s -P /home/xmu/playground/yi/workloads/ycsb-0.15.0/workloads/workload${program_name} -p "memcached.hosts=127.0.0.1" -p "memcached.port=11211" -p recordcount=1000000000 -p operationcount=666666667 -threads 36 >> /home/xmu/playground/yi/results/ycsb.${program_name}.txt &
    
    sleep 10; program_pid=$(pgrep java)

    echo "$program_pid" &
    
    while kill -0 "$program_pid" >/dev/null 2>&1
    do
        iostat -x >> /home/xmu/playground/yi/results/${program_name}.io.txt
        vmstat >> /home/xmu/playground/yi/results/${program_name}.vm.txt
        sleep 5
    done
}

run_NPB "bt" 36
sleep 100
run_NPB "cg" 32
sleep 100
run_NPB "dt BH" 36
sleep 100
run_NPB "ep" 36
sleep 100
run_NPB "ft" 32
sleep 100
run_NPB "is" 32
sleep 100
run_NPB "lu" 36
sleep 100
run_NPB "mg" 32
sleep 100
run_NPB "sp" 36
sleep 100
#run_G500_1
#sleep 100
run_G500_2
sleep 100
#run_load
#killall java
#sleep 50
#run_ycsb "a" 
#killall java
#sleep 100
#run_ycsb "b"
#killall java
#sleep 100
#run_ycsb "c" 
#killall java
#sleep 100
#run_ycsb "f"
#killall java
#sleep 100
#run_ycsb "w"
#killall java
#sleep 100
#run_ycsb "d"


echo "finish! exit 0"
