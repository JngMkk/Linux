#!/bin/bash

# Sticky bit이 설정된 경로 검색
echo "===== SUID, SGID, sticky bit PATH ====="

# 퍼미션으로 인해 접근 불가능한 디렉터리와 같은 경우에는 에러 미시지를 출력하는데
# 2>/dev/null을 사용함으로써 에러 메시지는 보여주지 않음
# 검색된 파일이나 디렉터리 중 sticky bit을 가지면 안되는 주요 파일 경로를 grep을 이용하여 검색
s_file=$(find / -perm -04000 -o -perm -02000 -o -perm -01000 2>/dev/null | grep -e 'dump$' -e 'lp*-lpd$' -e 'newgrp$' -e 'restore$' -e 'at$' -e 'traceroute$')

# 명령엉 실행 결과를 xagrs ls -dl 명령어를 만나 다시 상세 파일 목록으로 조회
find / -perm -04000 -o -perm -02000 -o -perm -01000 2>/dev/null | grep -e 'dump$' -e 'lp*-lpd$' -e 'newgrp$' -e 'restore$' -e 'at$' -e 'traceroute$' | xargs ls -dl



# World Writable 경로 검색
echo -e "\n===== World Writable Path ====="

# -xdev를 사용하여 xfs 파일시스템 유형을 가진 파일이나 디렉터리만 검색하게 됨
# grep -v 'l..........' 명령어를 이용하여 l로 시작하는 심볼릭 링크를 검색에서 제외함.
# 나머지 검색 결과는 awk '{print $NF}' 명령어를 만나 마지막 필드값인 파일 경로만 추출하게 됨
# 추출하게 된 경로는 xargs ls -dl 명령어를 만나 다시 상세 파일 목록으로 조회
w_file=$(find / -xdev -perm -2 -ls | grep -v 'l..........' | awk '{print $NF}')
find / -xdev -perm -2 -ls | grep -v 'l..........' | awk '{print $NF}' | xargs ls -dl



# 검색된 파일들의 파일 권한 변경 여부 확인
echo ""
read -p "Do you want to change file permission(y/n)? " result

if [[ $result == "y" ]]; then
    
    # sticky bit 경로 권한 변경
    echo -e "\n===== chmod SUID, SGID, sticky bit Path ====="
    for file in $s_file; do
        echo "chmod -s $file"
        chmod -s $file
    done

    # Writable 경로 권한 변경
    echo -e "\n===== chmod World Writable Path ====="
    for file in $w_file; do
        echo "chmod o-w $file"
        chmod o-w $file
    done

    # sticky bit 경로 변경 결과 조회
    echo -e "\n===== Result of sticky bit Path ====="
    for file in $s_file; do
        ls -dl $file
    done

    # Writable 경로 변경 결과 조회
    echo -e "\n===== Result of World Writable Path ====="
    for file in $w_file; do
        ls -dl $file
    done

# 파일 권한 변경을 원하지 않을 경우
elif [[ $result == "n" ]]; then
    exit

# 파일 권한 변경 여부 질의에 아무것도 입력하지 않았을 경우
elif [[ -z $result ]]; then
    echo "You didn't have any choice. Please check these files for security."
    exit

# 파일 권한 변경 여부 질의에 아무 글자나 입력했을 경우
else
    echo "You can choose only y or n"
    exit

fi