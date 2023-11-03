#!/bin/bash

conf_path=/etc/ssh/sshd_config

function restart_system(){
    echo "Restart sshd"
    systemctl restart sshd
}

function selinux(){
    # 운영체제가 레드햇 리눅스이고, port를 수정했을 경우
    if [[ $(cat /etc/*release | grep -i redhat | wc -l) > 1 ]] && [[ $1 == 1 ]]
    then
        # selinux에 해당 port 추가
        echo "Add port $port to selinux"
        
        # 레드햇 계열의 리눅스를 사용할 경우
        # 보안을 위해 사용되는 selinux의 ssh 포트에 변경한 포트를 추가함으로써
        # 추가한 port를 ssh 용도로 사용할 수 있도록 허용
        semanage port -a -t ssh_port_t -p tcp $port
    fi
}

# 환경 설정파일 백업
# 기존 환경 설정파일을 환경 설정을 변경하기 전에 만일을 대비해 백업본을 만들어 줌.
# ${변수명}을 사용한 이유는 뒤에 오는 .bak과 구분하기 위해서며,
# 언제 작업을 했는지 알기 쉽도록 date 명령문을 써 년월일을 파일명 뒤에 오도록 함
cp $conf_path ${conf_path}.bak.$(date +%Y%M%d)

case $1 in

    # Port 변경
    1)
    read -p "Please input port: " port
    
    # 기존 설정 정보를 사전에 확인하여 해당 라인을 변경할 수 있도록 하기 위해 변수 저장
    # 또한 설정을 변경했는데, 다른 값으로 다시 변경을 해야할 경우에도
    # 해당 라인을 찾아 변경하기 때문에 좀 더 정확도를 높일 수 있음
    exist_conf=$(cat $conf_path | grep -e '^#Port' -e '^Port')
    sed -i "s/$exist_conf/Port $port/g" $conf_path
    restart_system
    selinux $1
    ;;

    # PermitRootLogin 변경
    2)
    read -p "Please input PermitRootLogin yes or no: " rootyn
    exist_conf=$(cat $conf_path | grep -e '^#PermitRootLogin' -e '^PermitRootLogin')
    sed -i "s/$exist_conf/PermitRootLogin $rootyn/g" $conf_path
    restart_system
    ;;

    # PasswordAuthentication 변경
    3)
    read -p "Please input PasswordAuthentication yes or no: " pwyn
    exist_conf=$(cat $conf_path | grep -e '^#PasswordAuthentication' -e '^PasswordAuthentication')
    sed -i "s/$exist_conf/PasswordAuthentication $pwyn/g" $conf_path
    restart_system
    ;;

    # PubkeyAuthentication 변경
    4)
    read -p "Please input PubkeyAuthentication yes or no: " keyyn
    exist_conf=$(cat $conf_path | grep -e '^#PubkeyAuthentication' -e '^PubkeyAuthentication')
    sed -i "s/$exist_conf/PubkeyAuthentication $keyyn/g" $conf_path
    restart_system
    ;;
    *)

    echo "Please input with following number"
    echo "1) Port 2) PermitRootLogin 3) PasswordAuthentication 4) PubkeyAuthentication"
    echo "Usage: config-sshd.sh 2"

esac