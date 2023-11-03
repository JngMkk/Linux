#!/bin/bash

# 운영체제 타입 확인
ostype=$(cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")

# 네트워크 정보를 사용자로부터 입력 받음
echo "===== Network Devices ====="

# ip a는 네트워크 디바이스 목록을 확인하는 명령어
# ip a를 통해 확인한 네트워크 목록에서 grep을 이용해 숫자로 시작하는 라인만 검색한 후
# 첫 번째 인덱스와 두 번째 인덱스의 필드값을 추출함
# 그리고 다시 grep을 이용해 로컬 호스트를 의미하는 lo와
# 가상 네트워크 디바이스를 의미하는 v로 시작하는 네트워크와
# 컨테이너에서 사용하는 t로 시작하는 네트워크를 제외하면 실제 사용 네트워크가 조회됨
# docker0 제외 d
ip a | grep '^[0-9]' | awk '{print $1" "$2}' | grep -v -e 'lo' -e 'v' -e 't' -e 'd'

read -p "Please input network interface: " net_name
read -p "Please input network ip(ex: 192.168.122.10/24): " net_ip
read -p "Please input network gateway: " net_gw
read -p "Please input network dns: " net_dns

# 하나라도 입력하지 않았을 경우 입력하라는 메시지 출력 후 스크립트 종료
if [[ -z $net_name ]] || [[ -z $net_ip ]] || [[ -z $net_gw ]] || [[ -z $net_dns ]]
then
    echo "You need to input network information. Please retry this script"
    exit;
fi

# 운영체제가 페도라 계열일 경우 nmcli 명령어를 이용하여 네트워크 IP 설정
if [[ $ostype == "fedora" ]]
then
    nmcli con add con-name $net_name type ethernet ifname $net_name ipv4.address $net_ip ipv4.gateway $net_gw ipv4.dns $net_dns ipv4.method manual
    nmcli con up $net_name
# 운영체제가 데비안 계열일 경우 netplan에 yaml 파일을 생성하여 네트워크 IP 설정
elif [[ $ostype == "debian" ]]
then
    ip_chk=$(grep $net_name /etc/netplan/*.yaml | wc -l)
    # 설정하고자 하는 IP로 설정파일이 없을 경우 관련 네트워크 yaml 파일 생성
    if [ $ip_chk -eq 0 ]
    then
        # cat 명령어와 리다이렉션을 사용하여 EOF 다음 라인부터 EOF가 나올 때까지의 모든 문자열을
        # /etc/netplan/${net_name}.yaml 파일에 저장하겠다는 의미
        cat > /etc/netplan/${net_name}.yaml << EOF
network:
    version: 2
    renderer: networkd
    ethernets:
        $net_name:
            dhcp4: no
            dhcp6: no
            addresses: [$net_ip]
            gateway4: $net_gw
            nameservers:
                addresses: [$net_dns]
EOF
        echo "cat /etc/netplan/${net_name}.yaml"
        cat /etc/netplan/${net_name}.yaml
        echo "apply netplan"
        netplan apply
    else
        echo "This $net_name is configured already."
    fi
fi