#!/bin/bash

# flavor 하나만 생성할 경우
if [[ $1 == "" ]]; then
    read -p "Flavor name : " flname
    read -p "Number of VCPUs : " vcpus
    read -p "Memory size in MB : " rams
    read -p "Disk size in GB : " disks
    read -p "Ephemeral disk size in GB : " edisks

    # 인증 정보 export
    source ~/adminrc

    # CLI를 이용한 flavor 생성
    openstack flavor create \
    --vcpus $vcpus \
    --ram $rams \
    --disk $disks \
    --ephemeral $edisks \
    --public \
    $flname

# 여러개 생성할 경우
else
    if [[ -f $1 ]]; then
        # while read line; do ~ done < $1을 이용하여 한줄 한줄 읽어 들임
        # 여기서 line은 읽어 들인 해당 라인 내용을 저장할 변수명이며
        # done 다음에 나오는 $1은 파라미터로 받은 파일 경로
        while read line; do
            soruce ~/adminrc

            echo "Creating flavor $(echo $line | awk '{print $1}')"
            openstack flavor create \
            --vcpus $(echo $line | awk '{print $2}') \
            --ram $(echo $line | awk '{print $3}') \
            --disk $(echo $line | awk '{print $4}') \
            --ephemeral $(echo $line | awk '{print $5}') \
            --public \
            $(echo $line | awk '{print $1}')
        done < $1
    else
        echo "This is no file. Please try to run this script again."
        exit
    fi
fi