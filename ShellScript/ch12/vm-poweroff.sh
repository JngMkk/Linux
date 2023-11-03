#!/bin/bash

source ~/adminrc

if [[ -n "$1" ]]; then
    SHOST=$(openstack compute service list -c Binary -c Host -f value | grep compute | grep "$1" | awk '{print $2}')

    echo "This script will make a script about $SHOST instance power off."

    oepnstack server list --host $SHOST --all-projects -c ID -f value | awk '{print "openstack server stop "$1}' > /home/stack/vm_poweroff_$1.sh
else
    echo "Please input hostname."
    echo "ex) sh vm-poweroff.sh com01"
fi