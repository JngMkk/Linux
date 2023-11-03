#!/bin/bash

# 설정 변경 대상 노드들
nodes="host01 host02 host03"

# 환경 설정 확인 명령어
cmd1=:"cat /etc/lvm/lvm.conf | grep -e '^[[:space:]]*global_filter =' | wc -l"

# 환경 설정파일 백업 명령어
cmd2="cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak"

# 환경 설정 변경 명령어
# 해당 호스트의 /etc/lvm/lvm.conf 파일의 # global_filter로 시작하는 라인의
# 다음 줄(\1\n)에 global_filter=[ "r|.*" ]로 내용을 대체하라는 의미
# [ ""r|.*"" ]애 더블 쌍따옴표 기호를 넣은 건 문자열에서 쌍따옴표를 표현하기 위함
cmd3="sed -i 's/\(# global_filter =.*\)/\1\n global_filter = [ ""r|.*|"" ]/g' /etc/lvm/lvm.conf"

# LVM 관련 서비스 재시작 명령어
cmd4="systemctl restart lvm2*"

# 패스워드를 입력받을 때 외부로부터의 유출을 막기 위함
# read 명령어는 셸 스크립트 수행 중 프롬프트를 통해 사용자로부터 값을 입력받아 변수에 저장하여 사용할 수 있음.
# 이때 read 명령어를 그대로 사용하면 사용자가 입력하는 패스워드가 그대로 외부로 노출됨
# read 명령어 앞, 뒤로 stty -echo, stty echo를 사용하면 패스워드 유출을 막을 수 있음
stty -echo
read -p "Please input Hosts password: " pw
stty echo

# 사용자가 패스워드를 입력하지 않았다면
if [[ -z $pw ]]

then
    echo -e "\nYou need a password for this script. Please retry script"
    exit;

fi

for node in $nodes

do
    echo -e "\n$node"
    conf_chk=$(sshpass -p $pw ssh root@$node $cmd1)
    if [[ conf_chk -eq 0 ]]
    then
        # 설정 변경 전 백업
        echo "lvm.conf backup /etc/lvm/lmv.conf.bak"
        sshpass -p $pw ssh root@$node $cmd2
        
        # sed를 이용해 설정을 변경
        echo "/etc/lvm/lvm.conf reconfiguration"
        sshpass -p $pw ssh root@$node $cmd3

        # LVM 관련 서비스 재시작
        echo "LVM related service restart"
        sshpass -p $pw ssh root@$node $cmd4
    fi

done