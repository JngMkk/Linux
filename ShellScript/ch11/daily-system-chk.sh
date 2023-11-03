#!/bin/bash

cluster_servers="clus01 clus02 clus03"
container_servers="con01 con02 con03"
general_servers="gen01 gen02 gen03 gen04 gen05"
services="httpd mariadb"
grep_nic="-e eno1 -e eno3 -e enp24s0f0 -e enp24s0f1"

LOG_FILE=""

# 모니터링 로그 파일 생성
function make_logs() {
    DATE=$(date +%Y%m%d%H%M)
    LOG_FILE="/var/log/daily_system_chk/chk_system_$DATE.log"
    sudo touch $LOG_FILE
    sudo chmod 777 $LOG_FILE
}

# 모니터링 로그 파일 권한 변경
function change_log() {
    sudo chmod 644 $LOG_FILE
}

# 모니터링 결과 출력 후 로그 저장
function print_msg() {
    message=$1
    date=$(date +%Y-%m-%d %H:%M)
    echo "$date [daily_system_chk] $message" >> $LOG_FILE
    echo "$date $message"
}

function check_network() {
    print_msg "-----------------------------"
    print_msg "       Check Network         "
    print_msg "-----------------------------"
    down_link=$(ssh mon@$1 "ip link show | grep $grep_nic | grep 'state DOWN' | awk -F ': ' '{print $2}'")
    down_link_cnt=$(ssh mon@$1 "ip link show | grep $grep_nic | grep 'state DOWN' | wc -l")
    if [[ $down_link_cnt -eq 0 ]]; then
        print_msg "Network states are normal."
    else
        print_msg "Network $down_link is down. Please check network status."
    fi
}

function check_cpu() {
    print_msg "-----------------------------"
    print_msg "         Check CPU           "
    print_msg "-----------------------------"
    cpu_stat=$(ssh -q mon@$1 sudo mpstat | grep all | awk '{print $4}')
    print_msg "CPU usage is ${cpu_stat}%. If CPU usage is high, please check system cpu status"
}

function check_memory() {
    print_msg "-----------------------------"
    print_msg "       Check Memory          "
    print_msg "-----------------------------"
    mem_stat=$(ssh -q mon@$1 sudo free -h | grep -i mem | awk '{print $4}')
    print_msg "Memory free size is $mem_stat. If memory free size is low, please check system memory status."
}

make_logs
print_msg "-----------------------------"
print_msg "     Check System Power      "
print_msg "-----------------------------"

for i in {1..3}; do
    print_msg "##### NODE:: clus0$i #####"
    power_stat=$(ipmitool -I lanplus -H 192.168.0.1$i -L ADMINISTRATOR -U admin -P passw@rd! -v power status)
    print_msg "$power_stat"
done

for i in {1..3}; do
    print_msg "##### NODE:: con0$i #####"
    power_stat=$(ipmitool -I lanplus -H 192.168.0.2$i -L ADMINISTRATOR -U admin -P passw@rd! -v power status)
    print_msg "$power_stat"
done

for i in {1..5}; do
    print_msg "##### NODE:: gen0$i #####"
    power_stat=$(ipmitool -I lanplus -H 192.168.0.3$i -L ADMINISTRATOR -U admin -P passw@rd! -v power status)
    print_msg "$power_stat"
done

print_msg "-----------------------------"
print_msg "       Cluster Servers       "
print_msg "-----------------------------"

for i in $cluster_servers; do
    print_msg "##### NODE:: $i #####"
    if [ $i = "clus01" ]; then
        print_msg "-----------------------------"
        print_msg "      Check Clustering       "
        print_msg "-----------------------------"
        cluster_stat=$(ssh -q mon@$i sudo pcs status | grep 'failed' | wc -l)

        if [ $cluster_stat -eq 0 ]; then
            print_msg "Pacemaker status is normal."
        else
            print_msg "Please check Pacemaker."
            print_msg "$(ssh -q mon@$i sudo pcs status)"
        fi
    fi
    chk_network $i
    check_cpu $i
    check_memory $i
    
    print_msg "-----------------------------"
    print_msg "     Check Service Log       "
    print_msg "-----------------------------"
    for service in $services; do
        chk_log=$(ssh mon@$i sudo tail /var/log/$service/*.log | grep -i error | wc -l)
        if [[ $chk_log -eq 0 ]]; then
            echo "No error services logs. The $service is normal."
        else
            echo "Please check service $service logs"
            echo "$(ssh mon@$i sudo tail /var/log/$service/*.log | grep -i error)"
        fi
    done
done

print_msg "-----------------------------"
print_msg "     Container Servers       "
print_msg "-----------------------------"

for i in $container_servers; do
    print_msg "##### NODE:: $i #####"
    check_network $i
    check_cpu $i
    check_memory $i

    ostype=$(cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")
    if [[ $ostype == "fedora" ]]; then
        chk_docker=$(ssh -q mon@$i rpm -qa | grep -c docker)
        chk_podman=$(ssh -q mon@$i rpm -qa | grep -c podman)
    elif [[ $ostype == "debian" ]]; then
        chk_docker=$(ssh -q mon@$i dpkg -l | grep -c docker)
        chk_podman=$(ssh -q mon@$i dpkg -l | grep -c podman)
    else
        echo "bye.."
        exit
    fi
    if [[ $chk_docker -gt 0 ]]; then
        echo "This system's container engine is docker."
        chk_service=$(ssh -q mon@$i systemctl is-active docker)
        if [[ $chk_service == "active" ]]; then
            echo "Docker running state is active."
            chk_container=$(ssh -q mon@$i docker ps | grep -c seconds)
            if [[ $chk_container -gt 0 ]]; then
                echo "Please check your container state."
                echo "$(ssh -q mon@$i docker ps | grep seconds)"
            else
                echo "Container status is normal."
            fi
        else
            echo "Please check your docker status."
        fi
    elif [[ $chk_podman -gt 0 ]]; then
        echo "This system's container engine is podman."
        chk_service=$(ssh -q mon@$i systemctl is-active podman)
        if [[ $chk_service == "active" ]]; then
            echo "Podman running state is active."
            chk_container=$(ssh -q mon@$i podman ps | grep -c seconds)
            if [[ $chk_container -gt 0 ]]; then
                echo "Please check your container state."
                echo "$(ssh -q mon@$i podman ps | grep seconds)"
            else
                echo "Container status is normal."
            fi
        else
            echo "Please check your podman status."
        fi
    fi
done

print_msg "-----------------------------"
print_msg "       General Server        "
print_msg "-----------------------------"

for i in $general_servers; do
    print_msg "##### NODE:: $i #####"
    check_network $i
    check_cpu $i
    check_memory $i
done

change_log