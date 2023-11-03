#!/bin/bash

# 사용자 계정 및 패스워드가 입력되었는지 확인
# 입력된 문자열 길이가 0이 아니면 참을 리턴하는 문자열 연산자
# 사용자 계정과 패스워드가 모두 입력되었는지 확인하기 위한 && AND 논리 연산자 사용
# 입력되는 값이 외부에서 입력되는 파라미터이므로, [[]] 사용
if [[ -n $1 ]] && [[ -n $2 ]]
then

    # 외부에서 입력받은 사용자 계정과 패스워드를 변수에 배열로 할당
    # 여러 건의 사용자 생성과 패스워드 설정을 처리하기 위함
    UserList=($1)
    Password=($2)

    # for문을 이용하여 사용자 계정 생성
    # UserList의 길이만큼 사용자를 생성하기 위해 ${#배열형변수명[@]} 사용
    # 이렇게 표현하면 해당 변수의 길이를 구할 수 있음
    for (( i=0; i < ${#UserList[@]}; i++ ))
    do

        # if문을 사용하여 사용자 계정이 있는지 확인
        # 결과값을 개수로 세어 개수가 0이면 사용자를 아직 생성하지 않았다는 의미
        if [[ $(cat /etc/passwd | grep ${UserList[$i]} | wc -l) == 0 ]]
        then
            
            # 사용자 생성 및 패스워드 설정
            useradd ${UserList[$i]}
            echo ${Password[$i]} | passwd ${UserList[$i]} --stdin
        else
            # 사용자가 있다고 메시지를 보여줌
            echo "this user ${UserList[$i]} is existing."
        fi
    done

else
    # 사용자 계정과 패스워드를 입력하라는 메시지를 보여줌
    echo -e 'Please input user id and password.\nUsage: adduser-script.sh "user01 user02" "pw01 pw02"'

fi