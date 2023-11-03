#!/bin/bash

# 대상 서버와 계정정보 변수 저장
hosts="host01 host02"
account="root stack user01 user02"

# 대상 서버만큼 반복
for host in $hosts; do
    echo "######## $host ########"
    # 계정정보만큼 반복
    for user in $account; do
        # 패스워드 설정 주기 체크
        # 패스워드 변경주기 항목 중 Maximum number로 시작하는 항목의 값이 변경 전에는 99999로 설정되어 있음
        # 따라서 grep을 이용하여 99999로 조회되면 아직 패스워드 설정 주기가 설정되지 않았다는 것을 알 수 있음
        pw_chk=$(ssh -q root@$host "chage -l $user | grep 99999 | wc -l")

        # 패스워드 설정 주기가 설정되어 있지 않다면
        if [[ $pw_chk -eq 1 ]]; then

            # -M 옵션을 사용하여 패스워드 설정 주기를 90일로 설정
            # 페도라 계열의 리눅스 같은 경우 패스워드를 설정한 적이 없다면
            # 마지막 패스워드 변경일을 함께 설정하지 않기 때문에
            # -d 옵션을 사용하여 설정일을 마지막 패스워드 변경일로 설정할 수 있음
            ssh -q root@$host "chage -d $(date +%Y-%m-%d) -M 90 $user"
            echo "========> $user"

            # 설정 결과 확인
            ssh -q root@$host "chage -l $user"

        fi
    done
done