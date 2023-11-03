#!/bin/bash

# NTP를 설치할 대상 서버정보 저장
servers="host01 host02 host03"

# 페도라 계열의 리눅스는 /etc/redhat-release에서 운영체제 타입 확인
# 데비안 계열의 리눅스는 /etc/os-release에서 운영체제 타입 확인
# 이때, 운영체제 타입에 해당하는 옵션값이 바로 ID_LIKE
# 따라서 cat을 이용해 /etc/*release 파일을 확인하여 grep으로 ID_LIKE를 조회하면 해당 값 알 수 있음
# 여기서 값은 ID_LIKE="fedora" 혹은 ID_LIKE=debian으로 조회되기 때문에
# sed 명령어를 이용해 ID_LIKE=를 공백으로 변경함
# 그리고 "fedora" 같은 경우에는 앞뒤에 붙어 있는 쌍따옴표를 없애줘야 함
cmd1='cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g"'
cmd2=''

for server in $servers; do
    # 해당 서버의 운영체제 타입 확인
    ostype=$(sshpass -p $1 ssh root@$server $cmd1)

    # 운영체제가 페도라 계열인지 데비안 계열인지 체크
    if [[ $ostype == "fedora" ]]; then
        cmd2="yum install ntp -y"
    elif [[ $ostype == "debian" ]]; then
        cmd2="apt-get install ntp -y"
    fi

    # 해당 운영체제에 ntp 설치
    # 이때 ssh 접속 계정은 설치 명령어를 사용하므로
    # root 계정이나 root 권한을 가진 사용자 계정을 사용해야 함
    sshpass -p $1 ssh root@$server $cmd2

done