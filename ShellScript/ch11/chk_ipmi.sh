#!/bin/bash

ipmi_hosts="192.168.0.10 192.168.0.11 192.168.0.12 192.168.0.13"
ipmi_userid="admin"

read -p "Please input ipmi password : " ipmi_pw
if [[ -z $ipmi_pw ]]; then echo "You didn't input impi password. Please retry."; exit; fi

for host in $ipmi_hosts; do
    echo "######## IPMI HOST:: $host ########"
    power_stat=$(ipmitool -I lanplus -H $host -L ADMINISTRATOR -U $ipmi_userid -P $ipmi_pw -v power status)
    echo "$power_stat"
done