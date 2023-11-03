#!/bin/bash

hosts="host01 host02 host03"

for host in $hosts; do
    echo "######## HOST:: $host ########"
    chk_cpu=$(ssh -q mon@$host mpstat | grep all | awk '{print $4}')
    chk_mem=$(ssh -q mon@$host free -h | grep Mem | awk '{print $4}')

    echo "CPU usags is ${chk_cpu}%"
    echo "Memory free size is ${chk_mem}"
done