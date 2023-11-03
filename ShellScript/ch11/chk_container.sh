#!/bin/bash

hosts="host01 host02 host03"

for host in $hosts; do
    echo "######## HOST:: $host ########"
    ostype=$(cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")
    if [[ $ostype == "fedora" ]]; then
        chk_docker=$(ssh -q mon@$host rpm -qa | grep -c docker)
        chk_podman=$(ssh -q mon@$host rpm -qa | grep -c podman)
    elif [[ $ostype == "debian" ]]; then
        chk_docker=$(ssh -q mon@$host dpkg -l | grep -c docker)
        chk_podman=$(ssh -q mon@$host dpkg -l | grep -c podman)
    else
        echo "bye.."
        exit
    fi
    if [[ $chk_docker -gt 0 ]]; then
        echo "This system's container engine is docker."
        chk_service=$(ssh -q mon@$host systemctl is-active docker)
        if [[ $chk_service == "active" ]]; then
            echo "Docker running state is active."
            # seconds가 반복되면 문제가 있다고 볼 수 있음
            chk_container=$(ssh -q mon@$host docker ps | grep -c seconds)
            if [[ $chk_container -gt 0 ]]; then
                echo "Please check your container state."
                echo "$(ssh -q mon@$host docker ps | grep seconds)"
            else
                echo "Container status is normal."
            fi
        else
            echo "Please check your docker status."
        fi
    elif [[ $chk_podman -gt 0 ]]; then
        echo "This system's container engine is podman."
        chk_service=$(ssh -q mon@$host systemctl is-active podman)
        if [[ $chk_service == "active" ]]; then
            echo "Podman running state is active."
            chk_container=$(ssh -q mon@$host podman ps | grep -c seconds)
            if [[ $chk_container -gt 0 ]]; then
                echo "Please check your container state."
                echo "$(ssh -q mon@$host podman ps | grep seconds)"
            else
                echo "Container status is normal."
            fi
        else
            echo "Please check your podman status."
        fi
    else
        "No conatiner engine"
    fi
done