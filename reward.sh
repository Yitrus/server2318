#!/bin/bash

# perf script record --phys-data --max-size 1M -e mem-loads,mem-stores  --all-user # --cgroup htmm -- sleep 5

perf mem -D --phys-data record  --all-user --pid $(pgrep masim) sleep 10 # -k CLOCK_MONOTONIC  --exclude-perf

perf script -f > main.txt