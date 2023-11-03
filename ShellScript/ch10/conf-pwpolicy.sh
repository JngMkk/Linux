#!/bin/bash

# 운영체제 타입 확인
ostype=$(cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s\"//g")

# 운영체제가 페도라 계열일 경우
if [[ $ostype == "fedora" ]]
then
    # 설정 여부 체크
    conf_chk=$(cat /etc/pam.d/system-auth | grep 'local_users_only$' | wc -l)
    # 설정이 안되어 있으면 설정 후 설정 내용 확인
    if [ $conf_chk -eq 1 ]
    then
        # 소괄호로 묶어줌으로써 뒤에 오는 \1에 대한 우선 순위를 나타냄.
        # 이때 /\1은 local_users_only로 끝나는 라인의 바로 뒤에 오는 문자열을 붙여 쓰라는 듯.
        # 그래서, 셸 스크립트를 수행하고 나면 local_users_only로 끝나는 라인 뒤에 retry=3으로 시작하는 문자열들이 오게 됨.
        sed -i 's/\(local_users_only$\)/\1 retry=3 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root/g' /etc/pam.d/system-auth

        # password로 시작하며 requisite 문자열 사이에 스페이스나 공백이 오는 문자열을 찾으라는 의미
        cat /etc/pam.d/system-auth | grep '^password[[:space:]]*requisite'
    fi

# 운영체제가 데비안 계열일 경우
elif [[ $ostype == "debian" ]]
then
    # pam_pwquality.so가 설치되어 있는지 설정파일을 통해 확인
    conf_chk=$(cat /etc/pam.d/common-password | grep 'pam_pwquality.so' | wc -l)

    # 설치가 안되어 있으면 libpam-pwquality 설치
    if [ $conf_chk -eq 0 ]
    then
        apt install libpam-pwquality
    fi

    # 설정 여부 체크
    conf_chk=$(cat /etc/pam.d/common-password | grep 'retry=3$' | wc -l)

    # 설정이 안되어 있으면 설정 후 설정 내용 확인
    if [ $conf_chk -eq 1 ]
    then
        sed -i 's/\(retry=3$\)/\1 minlen=8 maxrepeat=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 difok=3 gecoscheck=1 reject_username enforce_for_root/g' /etc/pam.d/common-password
        echo "========================================================"
        cat /etc/pam.d/common-password | grep '^password[[:space:]]*requisite'
    fi
fi