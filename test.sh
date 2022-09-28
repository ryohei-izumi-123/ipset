#! /bin/bash
#################################################################################
## ISSUE DATE 2019/05/30
## VERSION    v3.0.1
## DESCRIPTION    IPTABLE MANAGEMENT
## REQUIRE    IPTABLE AND IPSET, GIT VERSION 2
## USAGE      ./test.sh
#################################################################################
# GET SSH PORT
sshPort()
{
    sudo echo $(sudo grep 'Port' /etc/ssh/sshd_config | sudo grep -v '#' | sudo awk '{ print $2 }')
}
getRealPort()
{
    sudo echo $(sudo netstat -tpln | sudo egrep '(Proto|ssh)' | sudo grep -v ':::' | sudo grep -v 'Proto' | sudo awk '{ print $4 }' | sudo cut -d: -f2 | sudo sort -u)
}
_REAL_SSH_PORT=`getRealPort`
_CONF_SSH_PORT=`sshPort`
# PORT DOES NOT MATCH
if [ ! "${_REAL_SSH_PORT}" -eq "${_CONF_SSH_PORT}" ]; then
    sudo echo "ERROR"
    exit 0
fi
# SET SSH PORT
SSH_PORT="${_CONF_SSH_PORT}"
# CHECK SSH PORT IS VALID
if [ "${SSH_PORT}" = "" ]; then
   sudo echo "ERROR"
   exit 0
fi
sudo echo "SSH PORT IS ${SSH_PORT}"
exit 0
#################################################################################
