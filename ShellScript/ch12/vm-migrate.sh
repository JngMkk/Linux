#!/bin/bash

source ~/adminrc

# 원 호스트명과 대상 호스트명 파라미터 저장
HNAME=$1
TNAME=$2

if [[ -n "$HNAME" ]] && [[ -N "$TNAME" ]]; then
    # 원 호스트명 조회 및 추출
    SHOST=$(openstack compute service list -c Binary -c Host -f value | grep compute | grep "$HNAME" | awk '{print $2}')
    
    # 대상 호스트명 조회 및 추출
    DHOST=$(openstack compute service list -c Binary -c Host -f value | grep compute | grep "$TNAME" | awk '{print $2}')
    echo "This script will make a script about $SHOST instance migrate to $DHOST"

    # 오픈스택 명령어를 이용한 인스턴스 마이그레이션 명령 생성
    # -v 옵션을 이용해 t라는 변수에 저장
    # print 명령어를 이용하여 앞에서 조회한 인스턴스 ID와 오픈스택 마이그레이션 명령어를 조합하여 출력
    # 해당 결과는 > 리다이렉션 기호를 이용하여 vm_migrate_$HNAME.sh에 저장
    openstack server list --host $SHOST --all-projects -c ID -f value | awk -v t=$DHOST '{print "openstack server migrate "$1" --live-migration --host "t" --wait"}' > ~/vm_migrate_$HNAME.sh

    echo "Make the script finish. you can see /home/stack/vm_migrate_$HNAME.sh"
else
    echo "Please input source and target hostnames."
    echo "ex) sh migrate_vm_command.sh com01 com02"
fi