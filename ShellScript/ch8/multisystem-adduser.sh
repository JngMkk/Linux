#!/bin/bash

for server in "host01 host02 host03"

do    
    # 여러 대의 시스템에 사용자 생성 및 패스워드 설정
    echo $server

    # ssh를 이용해 서버에 접속할 경우 for문에서 선언된 server라는 변수를 사용했음
    # ssh 접속 정보를 선언한 후에는 해당 서버에서 실행할 명령어를 적어주면 되는데
    # 이때 사용자 생성을 위한 useradd 명령어와 패스워드 설정을 위한 passwd 명령어를 사용함
    # 또한 명령어와 명령어에 넘겨줄 파라미터는 쌍따옴표로 묶어주면
    # 명령어가 어디서부터 어디까지인지를 정확하게 인식할 수 있음
    ssh root@$server "useradd $1"
    ssh root@$server "echo $2 | passwd $1 --stdin"

done