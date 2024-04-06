#!/bin/bash

CGROUP_NAME=htmm
CGROUP_DIR=/sys/fs/cgroup
NODE_ID=0
NODE_SIZE=2076MB
MAX=18446744073709551615


if [ "x${NODE_SIZE}" == "xmax" ]; then
    MEM_IN_BYTES=$MAX
else
    NODE_SIZE=${NODE_SIZE^^}

    if [[ ${NODE_SIZE} =~ "MB" ]]; then
	MEM_IN_BYTES=$(echo "(${NODE_SIZE::-2}+9268) *1024*1024" | bc)
    elif [[ ${NODE_SIZE} =~ "GB" ]]; then
	MEM_IN_BYTES=`echo ${NODE_SIZE::-2}*1024*1024*1024 | bc`
    fi
fi

echo ${MEM_IN_BYTES} | sudo tee ${CGROUP_DIR}/${CGROUP_NAME}/memory.max_at_node${NODE_ID}
# check if be set
echo "the size be limited"
cat ${CGROUP_DIR}/${CGROUP_NAME}/memory.max_at_node${NODE_ID}
