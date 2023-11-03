#!/bin/bash

# 인스턴스명 입력
# read 명령어는 외부 사용자로부터 파라미터를 직접 입력받을 때 사용하는 명령어
# -p 옵션은 프롬프트 메시지를 함께 보여줄 때 사용하는 옵션
# vmname은 사용자로부터 입력받은 문자열을 저장하기위해 사용하는 변수
read -p "Input instance name : " vmname

# 이미지 정보
echo "=== image List ==="

# 오픈스택 명령어를 사용할 때 -c 옵션을 사용하면 특정 컬럼 정보만 조회할 수 있음.
# 따라서 -c Name은 Name 컬럼만 출력하겠다는 의미.
# -f value 옵션은 출력 시 헤더값을 제외하고, 결과값만 출력하겠다는 의미
openstack image list -c Name -f value
read -p "Input image name : " image

# 네트워크 정보
echo "=== Network List ==="
openstack network list -c Name -f value
read -p "Input network name : " net

# Flavor 정보
echo "=== Flavor List ==="
openstack flavor list -c Name -f value
read -p "Input flavor name : " flavor

# 보안그룹 정보
echo "=== Security group List ==="
openstack security group list --project $OS_PROJECT_NAME -c Name -f value
read -p "Input security group name : " sec
secgrp=$(openstack security group list --project $OS_PROJECT_NAME -f value -c ID -c Name | grep "$sec\$" | awk '{print $1}')

# SSH 키 정보
echo "=== Keypair List ==="
openstack keypair list -c Name -f value
read -p "Input keypair name : " keypair

# 볼륨 생성
echo "=== Create volume ==="
read -p "Input volume size : " size
openstack volume create --size $size --image $image --bootable $vmname

# 인스턴스 생성
echo "Create Instance Starting"
openstack server create \
--volume $(openstack volume list --name $vmname -f value -c ID) \
--flavor $flavor \
--security-group $secgrp \
--key-name $keypair \
--network $net \
--wait \
$vmname