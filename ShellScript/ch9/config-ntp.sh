#!/bin/bash

ip=""
netmask=""
conf=""
service=""

# IP CIDR을 NetMask로 변경
function transfer_iprange(){

    # 외부로부터 입력받은 위치 매개변수를 매개변수 확장자 %를 사용하여 /로 시작하는 문자 뒷부분을 삭제함.
    # 예를 들어 10.10.10.0/24를 입력받았다면 /24는 삭제되고, 10.10.10.0만 남게 됨.
    ip=${1%/*}

    # 외부로부터 입력받은 위치 매개변수를 매개변수 확장자 #을 사용하여 / 앞부분의 문자열을 모두 삭제
    # 따라서 입력받은 IP에서 / 뒷부분의 CIDR에 해당하는 부분만 남게 됨.
    # 이때 해당 숫자가 16이라면 255.255.0.0 을 netmask 변수에 저장함
    if [[ ${1#*/} == 16 ]]; then netmask="255.255.0.0"; fi
    if [[ ${1#*/} == 23 ]]; then netmask="255.255.254.0"; fi
    if [[ ${1#*/} == 24 ]]; then netmask="255.255.255.0"; fi
    if [[ ${1#*/} == 28 ]]; then netmask="255.255.240.0"; fi
}

# 문자열 길이가 0이 아니라면
if [[ -n $1 ]]; then

    # 정규 표현식을 이용하여 IP 범위를 정상적으로 입력했는지 확인
    range_chk=$(echo "$1" | grep -E "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.0/[0-9]{2}$" | wc -l)
    
    # 정규 표현식과 다르다면 메시지를 출력하고 스크립트 종료
    if [[ range_chk -eq 0 ]]; then
        echo "This ip CIDR is wrong. Please input the right ip CIDR."
        exit;
    fi
fi

# chrony가 설치되어 있는지, npt가 설치되어 있는지 확인
if [[ -f /etc/chrony.conf ]]; then
    conf=/etc/chrony.conf
    service=chronyd.service
elif [[ -f /etc/ntp.conf ]]; then
    conf=/etc/ntp.conf
    service=ntpd.service
fi

# 환경 설정파일 백업
cp $conf ${conf}.bak.$(date +%Y%M%d)

# 서버 주소 변경
sed -i "s/^server/#server/g" $conf

# #server 3으로 시작하는 문자열 밑줄에
# a \server 127.127.1.0을 사용하여 server 127.127.1.0을 추가함
sed -i "/^#server 3/ a \server 127.127.1.0" $conf

# 파라미터로 입력받은 IP가 있고, chrony이면 allow 설정
if [[ -n $1 && -f /etc/chrony.conf ]]; then
    sed -i "/^#allow/ a \allow $1" $conf

# 파라미터로 입력받은 IP가 있고, ntp면 restrict 설정
elif [[ -n $1 && -f /etc/ntp.conf ]]; then
    transfer_iprange $1
    restrict="restrict $ip mask $netmask nomodify notrap"
    sed -i "/^#restrict/ a \restrict $restrict" $conf
fi

# 서비스 재시작
echo "systemctl restart $service"
systemctl restart $service

# 포트 추가
echo "firewall-cmd --add-service=ntp"
firewall-cmd --add-service=ntp
echo "firewall-cmd --add-service=ntp --permanant"
firewall-cmd --add-service=ntp --permanant