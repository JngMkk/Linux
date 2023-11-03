#!/bin/bash

hosts="cluster01 cluster02"

for host in $hosts; do
    echo "######## HOST:: $host ########"

    # pacemaker는 실행 중 서비스가 잘못되어 재시작을 한 경우나
    # health check를 하여 응답이 없었을 경우에는 Failed Action으로 해당 메시지를 보여줌
    # 따라서 이상 여부를 확인하기 위해 grep -i 옵션을 이용하여 해당 결과에 잘못된 경우가 있었는지 확인하고
    # -c 옵션을 이용하여 검색된 문자열의 개수를 체크함
    chk_cluster=$(ssh -q mon@$host sudo pcs status | grep -i -c 'failed')
    if [[ $chk_cluster -eq 0 ]]; then
        echo "Pacemaker status is normal."
    else
        echo "Please check pacemaker status"
        echo "********************************"
        echo "$(ssh -q mon@$host sudo pcs status)"
    fi
done