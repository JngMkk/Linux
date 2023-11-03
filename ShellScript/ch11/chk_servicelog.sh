#!/bin/bash

hosts="host01 host02"
services="httpd rabbitmq nginx"

for host in $hosts; do
    echo "######## HOST:: $host ########"
    for service in $services; do
        chk_log=$(ssh mon@$host sudo tail /var/log/$service/*.log | grep -i error | wc -l)
        if [[ $chk_log -eq 0 ]]; then
            echo "No error services logs. The $service is normal."
        else
            echo "Please check service $service logs and service $service"
            echo "$(ssh mon@$host sudo tail /var/log/$service/*.log | grep -i error)"
        fi
    done
done