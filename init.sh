#! /bin/bash
#################################################################################
## ISSUE DATE 2019/05/30
## VERSION    v3.0.1
## DESCRIPTION    IPTABLE MANAGEMENT
## REQUIRE    IPTABLE AND IPSET, GIT VERSION 2
## USAGE      ./init.sh
#################################################################################
sudo echo "INIT FIREWALL START..."
#################################################################################
# REMOVE V1 IF EXISTS
sudo rm -rf /root/ipset.sh

# CHANGE SCRIPT PERMISSION
sudo chmod +x /root/ipset/ipset.sh
sudo chmod +x /root/ipset/config.sh
sudo chmod +x /root/ipset/test.sh
sudo chmod +x /root/ipset/animation.sh

# RUN TEST "ERROR"
IPSET_TEST_RESULT=$(/root/ipset/test.sh)
# TEST IS ERROR
if [ "${IPSET_TEST_RESULT}" = "ERROR" ]; then
    sudo echo "CURRENT SSH PORT IS NOT OPEN OR INVALID!"
    exit 0
fi

# CONFIGURE MODULE(ONLY FIRST TIME)
/root/ipset/config.sh

# SET TO CRON(ONLY FIRST TIME)
sudo sed -i -e "s@10\s00\s\*\s\*\s1\s/root/ipset.sh@##REMOVE OLD IPSET@g" /var/spool/cron/root
sudo sed -i -e "s@00\s10\s\*\s\*\s\*\s/root/ipset/ipset.sh@##REMOVE NEW IPSET@g" /var/spool/cron/root
sudo sed -i -e "s@MAILTO=\"\"@##@g" /var/spool/cron/root
sudo cat << __EOF__ >> /var/spool/cron/root
MAILTO=""

# IPSET
00 10 * * * /root/ipset/ipset.sh
@reboot /root/ipset/ipset.sh
__EOF__
sudo service crond restart
sudo chkconfig crond on
sudo echo "INIT FIREWALL COMPLETE..."
exit 0
#################################################################################
