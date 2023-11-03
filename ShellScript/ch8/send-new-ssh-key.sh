#!/bin/bash

# 접속할 서버 정보, SSH 키 경로, 공개 키 경로를 변수에 저장
servers="host01 host02"
sshKey="$HOME/.ssh/key.pem"
sshPub="$HOME/.ssh/key.pem.pub"

# SSH Key 생성
# -f : output_keyfile
ssh-keygen -q -N "" -f $sshKey

# 생성된 SSH Key를 해당 서버에 복사
for server in $servers

do
    echo $server

    # 공개 키를 해당 서버에 복사할 때 해당 서버에 접속할 것인지 물어보는 메시지와
    # 패스워드가 무엇인지 물어보는 메시지를 없애기 위해
    # sshpass 명령어와 ssh-copy-id 명령어를 사용하여 복사
    # 패스워드는 보안을 위해 스크립트를 실행할 때 입력받는 것이 좋음.
    sshpass -p "$1" ssh-copy-id -i $sshPub stack@$server

done