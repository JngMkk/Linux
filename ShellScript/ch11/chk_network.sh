#!/bin/bash

hosts="host01 host02 host03"
grep_nic="-e eno1 -e eco3 -e enp24s0f0 -e enp24s0f1"

for host in $hosts; do
    echo "##### HOST:: $host #####"
    down_link=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | awk -F ': ' '{print $2}'")
    down_link_cnt=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | wc -l")
    if [[ $down_link_cnt -eq 0 ]]; then
        echo "Network states are normal."
    else
        echo "Network $down_link is down. Please check network status."
    fi
done