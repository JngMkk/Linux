#!/bin/bash

source ~/adminrc

if [[ -n "$1" ]]; then
    SHOST=$(openstack compute service list -c Binary -c Host -f value | grep compute | grep "$1" | awk '{print $2}')

    echo "This script will make a script about $SHOST instance start."

    openstack server list --host $SHOST --all-projects -c ID -f value | awk '{print "openstack server start "$1}' > ~/vm_start_$1.sh
else
    echo "Please input hostname."
    echo "ex) sh vm-start.sh com01"
fi