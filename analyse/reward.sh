#!/bin/bash

# perf script record --phys-data --max-size 1M -e mem-loads,mem-stores  --all-user # --cgroup htmm -- sleep 5

perf mem -D --phys-data record  --all-user --pid $(pgrep train) sleep 8 # -k CLOCK_MONOTONIC  --exclude-perf

# perf mem -D --phys-data record  --all-user -F 9 sleep 5

perf script -f > main.txt