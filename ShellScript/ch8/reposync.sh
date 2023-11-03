#!/bin/bash

# 리포지터리 목록을 입력받지 않고, 파일에 직접 입력해도 됨
repolist=$1
repopath=/var/www/html/repo/

# /etc/redhat-release에는 레드햇 리눅스 이름과 버전이 적혀 있음
# 여기서 버전 정보만 가져오기 위해 awk 명령어를 이용해
# 총 필드수 - 1번째의 문자열을 추출하면 레드햇 버전만 가져올 수 있음
osversion=$(cat /etc/redhat-release | awk '{print $(NF-1)}')

# 리포지터리 입력이 없으면 메시지를 보여주고 스크립트 종료
if [[ -z $1 ]]; then
    echo "Please input repository list. You can get repository from [yum repolist]"
    echo "Rhel7 Usage: reposync.sh \"rhel-7-server-rpms\""
    echo "Rhel8 Usage: reposync.sh \"rhel-8-for-x86_64-baseos-rpms\""
    exit;
fi

# 운영체제 버전에 따라 입력한 리포지터리만큼 동기화를 함
for repo in $repolist; do
    # OS가 Rhel7일 경우

    # 위에서 가져온 버전 정보는 아마도 7.x나 8.x일 것임
    # 여기서 가장 앞문자 하나를 추출하기 위해 ${변수:시작위치:길이}를 사용해
    # 운영체제 버전이 7인지 8인지 확인
    if [ ${osversion:0:1} == 7 ]; then
        reposync --gpgcheck -l -n --repoid=$repo --download_path=$repopath
        createrepo $repopath$repo
    
    # OS가 Rhel8일 경우
    elif [ ${osversion:0:1} == 8 ]; then
        reposync --download-metadata --repo=$repo -p $repopath
    fi

done