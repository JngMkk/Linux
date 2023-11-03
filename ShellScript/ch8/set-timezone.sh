#!/bin/bash

# Timezone을 설정할 대상 정보 및 명령어 저장
servers="host01 host02 host03"
cmd1="timedatectl status | grep 'Time zone'"
cmd2="timedatectl set-timezone $1"

# Timezone 또는 패스워드 둘 중 하나라도 입력하지 않았다면 스크립트 종료
# 연산자 -z는 변수의 길이가 0이면 true를 리턴하는 연산자로써
# timezone이나 접속하고자 하는 서버의 패스워드를 입력하지 않은 경우
# echo를 이용하여 메시지를 보여주고, 스크립트 종료
if [[ -z $1 ]] || [[ -z $1 ]]; then
    echo -e 'Please input timezone and password\nUsage: sh set-timezone.sh Seoul/Asia password'
    exit;
fi

for server in $servers

do
    # 해당 서버의 설정된 timezone 정보 조회
    # timedatectl status 명령어를 실행하면 "Time zone: Asia/Seoul (KST, +0900)"과 항목 확인 가능
    # 해당 Time zone이 포함된 라인만 조회하기 위해 grep 명령어를 사용하였고
    # 조회된 결과에서 awk를 이용하여 3번째 인덱스에 해당되는 timezone 정보만 추출해낼 수 있음
    timezone=$(sshpass -p $2 ssh root@$server "$cmd1" | awk '{print $3}')
    echo "$server: $timezone"

    # 설정하고자 하는 timezone과 조회된 timezone이 다른지 확인
    if [[ $timezone != $1 ]]
    
    then
        # timezone이 서로 다르면 해당 서버에 입력받은 timezone으로 설정
        sshpass -p $2 ssh root@$server $cmd2
        echo "$server timezone changed to $1"

    fi

done