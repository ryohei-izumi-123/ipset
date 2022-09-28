#! /bin/bash
#################################################################################
## ISSUE DATE 2019/05/30
## VERSION    v3.0.1
## DESCRIPTION    IPTABLE MANAGEMENT
## REQUIRE    IPTABLE AND IPSET
## USAGE      ./config.sh
#################################################################################
sudo echo "CONFIG FIREWALL START..."
#################################################################################
# GET DEFAULT LIST(NEED TO GET BEFORE FIRST RUN)
cd /root/ipset/
sudo wget -nv -O - http://nami.jp/ipv4bycc/cidr.txt.gz | sudo gunzip -c > /root/ipset/cidr.txt

sudo rm -rf /root/ipset/allow_ip && sudo rm -rf /root/ipset/deny_ip && sudo rm -rf /root/ipset/allow_country && sudo rm -rf /root/ipset/allow_ssh && sudo rm -rf /root/ipset/allow_zabbix && sudo rm -rf /root/ipset/allow_mysql && sudo rm -rf /root/ipset/allow_redis && sudo rm -rf /root/ipset/allow_node && sudo rm -rf /root/ipset/allow_jenkins && sudo rm -rf /root/ipset/allow_rabbitmq && sudo rm -rf /root/ipset/deny_country && sudo rm -rf /root/ipset/allow_mongodb
sudo touch /root/ipset/allow_ip && sudo touch /root/ipset/deny_ip && sudo touch /root/ipset/allow_country && sudo touch /root/ipset/allow_ssh && sudo touch /root/ipset/allow_zabbix && sudo touch /root/ipset/allow_mysql && sudo touch /root/ipset/allow_redis && sudo touch /root/ipset/allow_node && sudo touch /root/ipset/allow_jenkins && sudo touch /root/ipset/allow_rabbitmq && sudo touch /root/ipset/deny_country && sudo touch /root/ipset/allow_mongodb
sudo chmod +x /root/ipset/allow_ip && sudo chmod +x /root/ipset/deny_ip && sudo chmod +x /root/ipset/allow_country && sudo chmod +x /root/ipset/allow_ssh && sudo chmod +x /root/ipset/allow_zabbix && sudo chmod +x /root/ipset/allow_mysql && sudo chmod +x /root/ipset/allow_redis && sudo chmod +x /root/ipset/allow_node && sudo chmod +x /root/ipset/allow_jenkins && sudo chmod +x /root/ipset/allow_rabbitmq && sudo chmod +x /root/ipset/deny_country && sudo chmod +x /root/ipset/allow_mongodb

# FOR HTTP/HTTPS
sudo cat /root/ipset/allow_ip.ini >> /root/ipset/allow_ip
# FOR REDIS
sudo cat /root/ipset/allow_ip.ini >> /root/ipset/allow_redis
# FOR MYSQL
sudo cat /root/ipset/allow_ip.ini >> /root/ipset/allow_mysql
# FOR NODE
sudo cat /root/ipset/allow_ip.ini >> /root/ipset/allow_node
# FOR RABBITMQ
sudo cat /root/ipset/allow_ip.ini >> /root/ipset/allow_rabbitmq
# FOR MONGODB
sudo cat /root/ipset/allow_ip.ini >> /root/ipset/allow_mongodb
# FOR JENKINS
sudo cat /root/ipset/allow_ip.ini >> /root/ipset/allow_jenkins
# FOR ZABBIX
sudo cat /root/ipset/allow_zabbix.ini >> /root/ipset/allow_zabbix
# FOR SSH
sudo cat /root/ipset/allow_ssh.ini >> /root/ipset/allow_ssh
# COUNTRY FILTER
sudo cat /root/ipset/allow_country.ini >> /root/ipset/allow_country
# COUNTRY FILTER BY BLACKLIST
sudo cat /root/ipset/deny_country.ini >> /root/ipset/deny_country
# BLACKLIST
sudo cat /root/ipset/deny_ip.ini >> /root/ipset/deny_ip
#################################################################################
sudo echo "CONFIG FIREWALL COMPLETE..."
exit 0
#################################################################################
