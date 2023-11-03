#!/bin/bash

hosts="host01 host02"
services="httpd haproxy rabbitmq"
ports="80 443 8080 5672 15672"

for host in $hosts; do
    echo "######## HOST:: $host ########"
    
    for service in $services; do
        chk_service=$(ssh mon@$host sudo systemctl is-active $service)
        if [[ $chk_service == "active" ]]; then
            echo "$service state is active."
        else
            echo "$service state is inactive. Please check $service"
        fi
    done

    echo "***************************************"
    for port in $ports; do
        chk_port=$(ssh mon@$host sudo netstat -ntpl | grep $port | wc -l)
        if [[ $chk_port -gt 0 ]]; then
            echo "This port $port is open."
        else
            echo "This port $port is not found. Please check your system."
        fi
    done
    echo "***************************************"
done