#!/bin/bash

source ~/adminrc

echo "This script will make a script about instance delete."

openstack server list --all-projects -c ID -f value | awk '{print "openstack server delete "$1}' > ~/vm_delete.sh
