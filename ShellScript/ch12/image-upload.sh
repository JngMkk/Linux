#!/bin/bash

read -p "Please input image path : " imgpath

if [[ -f $imgpath ]]; then
    read -p "Please input image name : " imgname
    # 인증 파일 export
    source ~/adminrc
    openstack image create \
    --file $imgpath \
    --container-format bare \
    --disk-format $(ls $imgpath | awk -F . '$NF == "qcow2" ? type="qcow2" : type="raw" {print type}') \
    --public \
    $imgname
else
    echo "This is no image. Please try to run the script again."
    exit
fi