#!/bin/bash

# ./scripts_autonuma/ccurand.sh 
# ./scripts_autonuma/xsb.sh 
# ./scripts_tpp/ccurand.sh 
./scripts_tpp/xsb.sh 

# ./scripts_autonuma/dlrm.sh 
# ./scripts_tpp/dlrm.sh 

# ./scripts_autonuma/ssspweb.sh 
# ./scripts_tpp/ssspweb.sh 

# BENCH_NAME="1 2 3 4 5 6" 
# BENCH_NAME="bs1 bs2 bs3 bs4 bs5 bs6" 

# for BENCH in ${BENCH_NAME};
# do
# 	./scripts_autonuma/masim.sh -V bs -R ${BENCH}
# done


# for BENCH in ${BENCH_NAME};
# do
# 	./scripts_tpp/masim.sh -V bs -R ${BENCH}
# done

# for BENCH in ${BENCH_NAME};
# do
# 	./scripts_at08/masim.sh -V as -R ${BENCH}
# done

# ycsb-0.15.0/bin/ycsb load memcached -s -P ycsb-0.15.0/workloads/workloada -p "memcached.hosts=127.0.0.1" -p "memcached.port=11211" -p recordcount=1000000000 -threads 64 >> outRun.ycsb.load

# ./scripts_autonuma/ycsb_a.sh
# ./scripts_tpp/ycsb_a.sh

# ./scripts_autonuma/ycsb_b.sh
# ./scripts_tpp/ycsb_b.sh

# ./scripts_autonuma/ycsb_c.sh
# ./scripts_tpp/ycsb_c.sh

# ./scripts_autonuma/ycsb_f.sh
# ./scripts_tpp/ycsb_f.sh

# ./scripts_autonuma/ycsb_d.sh
# ./scripts_tpp/ycsb_d.sh

# ./scripts_autonuma/ycsb_e.sh
# ./scripts_tpp/ycsb_e.sh

# ./scripts_at08/ycsb_a.sh
# ./scripts_at08/ycsb_b.sh
# ./scripts_at08/ycsb_c.sh
# ./scripts_at08/ycsb_f.sh
# ./scripts_at08/ycsb_d.sh
# ./scripts_at08/ycsb_e.sh

# ./scripts_multiclock/ycsb_a.sh
# ./scripts_multiclock/ycsb_b.sh
# ./scripts_multiclock/ycsb_c.sh
# ./scripts_multiclock/ycsb_f.sh
# ./scripts_multiclock/ycsb_d.sh
# ./scripts_multiclock/ycsb_e.sh