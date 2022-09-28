#! /bin/bash
#################################################################################
## ISSUE DATE 2019/05/30
## VERSION    v3.0.1
## DESCRIPTION    IPTABLE MANAGEMENT
## REQUIRE    IPTABLE AND IPSET, GIT VERSION 2
## USAGE      ./ipset.sh
## PLEASE SET THE WHITEL LIST ON  BLACK LIST
## WHITEL LIST            ${DIRECTORY}allow_ip
## WHITE LIST BY COUNTRY      ${DIRECTORY}allow_country
## BLACK LIST             ${DIRECTORY}deny_ip
## @TROUBLESHOOTING:
## `zsh: ./ipset.sh: bad interpreter: /bin/bash^M: no such file or directory`
## For `MAC`: `perl -i -pe 'y|\r||d' ./ipset.sh`
#################################################################################
# version
IPSET_MODULE_VERSION="v3.0.1"

# allow httpd open
ALLOW_HTTP_OPENED=$1

# allow ssh open
ALLOW_SSHD_OPENED=$2

# get ssh port
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
# port does not match
if [ ! "${_REAL_SSH_PORT}" -eq "${_CONF_SSH_PORT}" ]; then
    sudo echo "CURRENT SSH PORT IS NOT OPEN! "
    exit 1
fi
# set ssh port
SSH_PORT="${_CONF_SSH_PORT}"
# pre define port
IDENT_PORT=113
HTTP_PORT=80,443,8080,8000
ZABBIX_PORT=10050
MYSQL_PORT=3306
REDIS_PORT=6379
NODE_PORT=3841,3842,3843
RABBITMQ_PORT=4369,5672,15672,25672
JENKINS_PORT=8082
MONGODB_PORT=27017,27018,27019
PROXY_PORT=18903,60088,10072
#################################################################################
DIRECTORY=/root/ipset/
#################################################################################
# validate ssh port
if [ "${SSH_PORT}" = "" ]; then
   sudo echo "NO SSH_PORT!"
   exit 1
fi
sudo echo "SSH PORT IS ${SSH_PORT}"
#################################################################################
if [ ! -d "$DIRECTORY" ]; then
    sudo mkdir ${DIRECTORY}
    sudo chmod +x ${DIRECTORY}
fi
#################################################################################
cd ${DIRECTORY}
#################################################################################
# pid
PID=$$
# show version
sudo echo "[IPSET MODULE] VERSION: ${IPSET_MODULE_VERSION}"
# show pid
sudo echo "PID: ${PID}"
#################################################################################
# remove old files
if [ -s ${DIRECTORY}cidr.txt ]; then
    if [ -s ${DIRECTORY}cidr.txt.old ]; then
        sudo rm -rf ${DIRECTORY}cidr.txt.old
    fi
    sudo mv ${DIRECTORY}cidr.txt ${DIRECTORY}cidr.txt.old
fi
#################################################################################
# download
sudo wget -nv -O - http://nami.jp/ipv4bycc/cidr.txt.gz | sudo gunzip -c > ${DIRECTORY}cidr.txt
IPDIFF=$(sudo diff ${DIRECTORY}cidr.txt.old ${DIRECTORY}cidr.txt | sudo grep -c "^<")
IPNUMS=sudo wc -l ${DIRECTORY}cidr.txt | sudo awk '{print $1}'
#################################################################################
if [ $IPDIFF -gt 200 ] && [ $IPNUMS -lt 100000 ]; then
    sudo echo "ERROR"
    exit 1
else
    # create ipset
    sudo ipset create -exist SSHLIST hash:net
    sudo ipset create -exist REDISLIST hash:net
    sudo ipset create -exist NODELIST hash:net
    sudo ipset create -exist MYSQLLIST hash:net
    sudo ipset create -exist ZABBIXLIST hash:net
    sudo ipset create -exist JENKINSLIST hash:net
    sudo ipset create -exist RABBITMQLIST hash:net
    sudo ipset create -exist MONGODBLIST hash:net
    sudo ipset create -exist WHITELIST hash:net
    sudo ipset create -exist BLACKLIST hash:net

    # reset ipset
    sudo ipset flush SSHLIST
    sudo ipset flush REDISLIST
    sudo ipset flush NODELIST
    sudo ipset flush MYSQLLIST
    sudo ipset flush ZABBIXLIST
    sudo ipset flush JENKINSLIST
    sudo ipset flush RABBITMQLIST
    sudo ipset flush MONGODBLIST
    sudo ipset flush WHITELIST
    sudo ipset flush BLACKLIST

    # accept ip(whitelist)
    ALLOW_FILE=${DIRECTORY}allow_ip
    while read allow_ip; do
        sudo echo "ADDED INTO WHITELIST:${allow_ip}"
        sudo ipset add WHITELIST $allow_ip
    done < $ALLOW_FILE

    # deny ip(blacklist)
    DENY_FILE=${DIRECTORY}deny_ip
    while read deny_ip; do
        sudo echo "ADDED INTO BLACKLIST:${deny_ip}"
        sudo ipset add BLACKLIST $deny_ip
    done < $DENY_FILE

    # ssh
    SSH_FILE=${DIRECTORY}allow_ssh
    while read allow_ssh; do
        sudo echo "ADDED INTO SSH LIST:${allow_ssh}"
        sudo ipset add SSHLIST $allow_ssh
    done < $SSH_FILE

    # redis
    REDIS_FILE=${DIRECTORY}allow_redis
    while read allow_redis; do
        sudo echo "ADDED INTO REDIS LIST:${allow_redis}"
        sudo ipset add REDISLIST $allow_redis
    done < $REDIS_FILE

    # node
    NODE_FILE=${DIRECTORY}allow_node
    while read allow_node; do
        sudo echo "ADDED INTO NODE LIST:${allow_node}"
        sudo ipset add NODELIST $allow_node
    done < $NODE_FILE

    # mysql
    MYSQL_FILE=${DIRECTORY}allow_mysql
    while read allow_mysql; do
        sudo echo "ADDED INTO MYSQL LIST:${allow_mysql}"
        sudo ipset add MYSQLLIST $allow_mysql
    done < $MYSQL_FILE

    # zabbix
    ZABBIX_FILE=${DIRECTORY}allow_zabbix
    while read allow_zabbix; do
        sudo echo "ADDED INTO ZABBIX LIST:${allow_zabbix}"
        sudo ipset add ZABBIXLIST $allow_zabbix
    done < $ZABBIX_FILE

    # jenkins
    JENKINS_FILE=${DIRECTORY}allow_jenkins
    while read allow_jenkins; do
        sudo echo "ADDED INTO JENKINS LIST:${allow_jenkins}"
        sudo ipset add JENKINSLIST $allow_jenkins
    done < $JENKINS_FILE

    # rabbitmq
    RABBITMQ_FILE=${DIRECTORY}allow_rabbitmq
    while read allow_rabbitmq; do
        sudo echo "ADDED INTO RABBITMQ LIST:${allow_rabbitmq}"
        sudo ipset add RABBITMQLIST $allow_rabbitmq
    done < $RABBITMQ_FILE

    # mongodb
    MONGODB_FILE=${DIRECTORY}allow_mongodb
    while read allow_mongodb; do
        sudo echo "ADDED INTO MONGODB LIST:${allow_mongodb}"
        sudo ipset add MONGODBLIST $allow_mongodb
    done < $MONGODB_FILE

    # country filter(whitelist/blacklist)
    DIRECTORY=/root/ipset/
    CIDR_FILE=${DIRECTORY}cidr.txt
    ALLOW_COUNTRY_FILE=${DIRECTORY}allow_country
    DENY_COUNTRY_FILE=${DIRECTORY}deny_country

    while read allow_country; do
        sudo sed -n "s/^\(${allow_country}\)\t//p" ${CIDR_FILE} | while read ALLOW_ADDRESS; do
            sudo echo "ADDED INTO WHITELIST COUNTRY: ${allow_country} IP: ${ALLOW_ADDRESS}"
            sudo ipset add WHITELIST $ALLOW_ADDRESS
        done
    done < $ALLOW_COUNTRY_FILE

    if [ "$ALLOW_HTTP_OPENED" = "1" ]; then
        while read deny_country; do
            sudo sed -n "s/^\(${deny_country}\)\t//p" ${CIDR_FILE} | while read DENY_ADDRESS; do
                sudo echo "ADDED INTO BLACKLIST COUNTRY: ${deny_country} IP: ${DENY_ADDRESS}"
                sudo ipset add BLACKLIST $DENY_ADDRESS
            done
        done < $DENY_COUNTRY_FILE
    fi

    # save ipset
    sudo ipset save
    # sudo ipset save | tee restore_command
    # sudo ipset restore < restore_command
    sudo echo "SAVE IPSET"

    # sudo service iptables stop
    sudo service iptables start

    # iptables 初期化
    sudo iptables -F INPUT
    sudo iptables -F OUTPUT
    sudo iptables -F FORWARD
    sudo iptables -F # テーブル初期化
    sudo iptables -X # チェーンを削除
    sudo iptables -Z # パケットカウンタ・バイトカウンタをクリア

    # 受信/ 送信 / 通過
    sudo iptables -P INPUT DROP
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -P FORWARD DROP

    sudo iptables -A INPUT -p tcp ! --tcp-flags SYN,RST,ACK SYN -m state --state NEW -j DROP
    sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    ## ポート開放 ##
    sudo iptables -A INPUT -i lo -j ACCEPT
    sudo iptables -A OUTPUT -o lo -j ACCEPT

    # IP Spoofing
    sudo iptables -A INPUT -i eth0 -s 127.0.0.0/8 -j DROP
    sudo iptables -A INPUT -i eth0 -s 127.0.0.1/8 -j DROP
    sudo iptables -A INPUT -i eth0 -s 10.0.0.0/8 -j DROP
    sudo iptables -A INPUT -i eth0 -s 172.16.0.0/12 -j DROP
    sudo iptables -A INPUT -i eth0 -s 192.168.0.0/16 -j DROP
    sudo iptables -A INPUT -i eth0 -s 192.168.0.0/24  -j DROP
    sudo iptables -A INPUT -i eth0 -s 169.254.0.0/16  -j DROP
    sudo iptables -A INPUT -i eth0 -s 192.0.2.0/24  -j DROP

    ###########################################################
    # 攻撃対策: Ping of Death, Ping Flood
    ###########################################################
    sudo iptables -N PING_ATTACK
    sudo iptables -A PING_ATTACK -m length --length :85 -m limit --limit 1/s --limit-burst 4 -j ACCEPT
    sudo iptables -A PING_ATTACK -j LOG --log-prefix "[IPTABLES PINGATTACK] : " --log-level=debug
    sudo iptables -A PING_ATTACK -j DROP
    sudo iptables -A INPUT -p icmp --icmp-type 8 -j PING_ATTACK
    # 毎秒1回を超えるpingが60回続いたら破棄
    sudo iptables -N PING_OF_DEATH # "PING_OF_DEATH" という名前でチェーンを作る
    sudo iptables -A PING_OF_DEATH -p icmp --icmp-type echo-request \
         -m hashlimit \
         --hashlimit 1/s \
         --hashlimit-burst 60 \
         --hashlimit-htable-expire 300000 \
         --hashlimit-mode srcip \
         --hashlimit-name t_PING_OF_DEATH \
         -j RETURN

    # 制限を超えたICMPを破棄
    sudo iptables -A PING_OF_DEATH -j LOG --log-prefix "ping_of_death_attack: "
    sudo iptables -A PING_OF_DEATH -j DROP

    # ICMP は "PING_OF_DEATH" チェーンへジャンプ
    sudo iptables -A INPUT -p icmp --icmp-type echo-request -j PING_OF_DEATH

    ###########################################################
    # Smurf (multicast address, broadcast address)
    ###########################################################
    sudo iptables -A INPUT -d 255.255.255.255 -j DROP
    sudo iptables -A INPUT -d 224.0.0.1 -j DROP
    sudo iptables -A INPUT -d 192.168.0.255 -j DROP

    ###########################################################
    # Auth/IDENT
    ###########################################################
    # 攻撃対策: IDENT port probe
    # identを利用し攻撃者が将来の攻撃に備えるため、あるいはユーザーの
    # システムが攻撃しやすいかどうかを確認するために、ポート調査を実行
    # する可能性があります。
    # DROP ではメールサーバ等のレスポンス低下になるため REJECTする
    ###########################################################
    sudo iptables -A INPUT -p tcp --dport 113 -i eth0 -j REJECT --reject-with tcp-reset
    # sudo iptables -A INPUT -p tcp -m multiport --dports $IDENT_PORT -j REJECT --reject-with tcp-reset

    ###########################################################
    # 攻撃対策: SSH Brute Force
    # SSHはパスワード認証を利用しているサーバの場合、パスワード総当り攻撃に備える。
    # 1分間に5回しか接続トライをできないようにする。
    # SSHクライアント側が再接続を繰り返すのを防ぐためDROPではなくREJECTにする。
    # SSHサーバがパスワード認証ONの場合、以下をアンコメントアウトする
    ###########################################################
    sudo iptables -A INPUT -p tcp --syn -m multiport --dports $SSH_PORT -m recent --name ssh_attack --set
    sudo iptables -A INPUT -p tcp --syn -m multiport --dports $SSH_PORT -m recent --name ssh_attack --rcheck --seconds 60 --hitcount 5 -j LOG --log-prefix "ssh_brute_force: "
    sudo iptables -A INPUT -p tcp --syn -m multiport --dports $SSH_PORT -m recent --name ssh_attack --rcheck --seconds 60 --hitcount 5 -j REJECT --reject-with tcp-reset

    ###########################################################
    # 攻撃対策: SYN Flood Attack
    # この対策に加えて Syn Cookie を有効にすべし。
    ###########################################################
    sudo iptables -N SYN_FLOOD # "SYN_FLOOD" という名前でチェーンを作る
    sudo iptables -A SYN_FLOOD -p tcp --syn \
         -m hashlimit \
         --hashlimit 200/s \
         --hashlimit-burst 3 \
         --hashlimit-htable-expire 300000 \
         --hashlimit-mode srcip \
         --hashlimit-name t_SYN_FLOOD \
         -j RETURN

    # 解説
    # -m hashlimit                       ホストごとに制限するため limit ではなく hashlimit を利用する
    # --hashlimit 200/s                  秒間に200接続を上限にする
    # --hashlimit-burst 3                上記の上限を超えた接続が3回連続であれば制限がかかる
    # --hashlimit-htable-expire 300000   管理テーブル中のレコードの有効期間（単位：ms
    # --hashlimit-mode srcip             送信元アドレスでリクエスト数を管理する
    # --hashlimit-name t_SYN_FLOOD       /proc/net/ipt_hashlimit に保存されるハッシュテーブル名
    # -j RETURN                          制限以内であれば、親チェーンに戻る

    # 制限を超えたSYNパケットを破棄
    sudo iptables -A SYN_FLOOD -j LOG --log-prefix "syn_flood_attack: "
    sudo iptables -A SYN_FLOOD -j DROP

    # SYNパケットは "SYN_FLOOD" チェーンへジャンプ
    sudo iptables -A INPUT -p tcp --syn -j SYN_FLOOD

    ###########################################################
    # 攻撃対策: Stealth Scan
    ###########################################################
    sudo iptables -N STEALTH_SCAN # "STEALTH_SCAN" という名前でチェーンを作る
    sudo iptables -A STEALTH_SCAN -j LOG --log-prefix "stealth_scan_attack: "
    sudo iptables -A STEALTH_SCAN -j DROP

    # ステルススキャンらしきパケットは "STEALTH_SCAN" チェーンへジャンプする
    sudo iptables -A INPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j STEALTH_SCAN
    sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j STEALTH_SCAN

    sudo iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN         -j STEALTH_SCAN
    sudo iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST         -j STEALTH_SCAN
    sudo iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j STEALTH_SCAN

    sudo iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j STEALTH_SCAN
    sudo iptables -A INPUT -p tcp --tcp-flags ACK,FIN FIN     -j STEALTH_SCAN
    sudo iptables -A INPUT -p tcp --tcp-flags ACK,PSH PSH     -j STEALTH_SCAN
    sudo iptables -A INPUT -p tcp --tcp-flags ACK,URG URG     -j STEALTH_SCAN

    ###########################################################
    # 攻撃対策: フラグメントパケットによるポートスキャン,DOS攻撃
    # namap -v -sF などの対策
    ###########################################################
    sudo iptables -A INPUT -f -j LOG --log-prefix 'fragment_packet:'
    sudo iptables -A INPUT -f -j DROP

    ###########################################################
    # 攻撃対策: HTTP DoS/DDoS Attack
    ###########################################################
    sudo iptables -N HTTP_DOS # "HTTP_DOS" という名前でチェーンを作る
    sudo iptables -A HTTP_DOS -p tcp -m multiport --dports $HTTP_PORT \
         -m hashlimit \
         --hashlimit 1/s \
         --hashlimit-burst 100 \
         --hashlimit-htable-expire 300000 \
         --hashlimit-mode srcip \
         --hashlimit-name t_HTTP_DOS \
         -j RETURN

    # 解説
    # -m hashlimit                       ホストごとに制限するため limit ではなく hashlimit を利用する
    # --hashlimit 1/s                    秒間1接続を上限とする
    # --hashlimit-burst 100              上記の上限を100回連続で超えると制限がかかる
    # --hashlimit-htable-expire 300000   管理テーブル中のレコードの有効期間（単位：ms
    # --hashlimit-mode srcip             送信元アドレスでリクエスト数を管理する
    # --hashlimit-name t_HTTP_DOS        /proc/net/ipt_hashlimit に保存されるハッシュテーブル名
    # -j RETURN                          制限以内であれば、親チェーンに戻る

    # 制限を超えた接続を破棄
    sudo iptables -A HTTP_DOS -j LOG --log-prefix "http_dos_attack: "
    sudo iptables -A HTTP_DOS -j DROP

    # HTTPへのパケットは "HTTP_DOS" チェーンへジャンプ
    sudo iptables -A INPUT -p tcp -m multiport --dports $HTTP_PORT -j HTTP_DOS

    # drop black list ips
    #sudo iptables -A INPUT -m set --match-set BLACKLIST src -j DROP

    # open dns amp
    sudo iptables -N DNSAMP
    sudo iptables -A DNSAMP -m recent --name dnsamp --set
    sudo iptables -A DNSAMP -m recent --name dnsamp --rcheck --seconds 60 --hitcount 5 -j LOG --log-prefix "[IPTABLES DNSAMP] : " --log-level=debug
    sudo iptables -A DNSAMP -m recent --name dnsamp --rcheck --seconds 60 --hitcount 5 -j DROP
    sudo iptables -A DNSAMP -j ACCEPT
    sudo iptables -A INPUT -p udp -m state --state NEW --dport 53 -i eth0 -j DNSAMP
    sudo iptables -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT

    # SHADOWSOCKS-R AND SQUID PORT
    sudo iptables -A INPUT -p udp -m state --state NEW -m multiport --dports $PROXY_PORT -j ACCEPT
    sudo iptables -A INPUT -p tcp -m state --state NEW -m multiport --dports $PROXY_PORT -j ACCEPT

    # open smtps
    sudo iptables -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT

    # open imaps
    sudo iptables -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT

    # open pop3
    sudo iptables -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT

    # open smtp tcp
    sudo iptables -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT

    # open submission
    sudo iptables -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT

    # open ssh
    if [ "$ALLOW_SSHD_OPENED" = "1" ]; then
        sudo echo "ALLOW_SSHD_OPENED: NONE STRICT MODE!"
        sudo iptables -I INPUT -m state --state NEW -p tcp --dport $SSH_PORT -m set --match-set WHITELIST src -j ACCEPT
    else
        sudo echo "ALLOW_SSHD_OPENED: STRICT MODE!"
        sudo iptables -I INPUT -m state --state NEW -p tcp --dport $SSH_PORT -m set --match-set SSHLIST src -j ACCEPT
    fi

    sudo iptables -I INPUT -m state --state NEW -p tcp --dport $REDIS_PORT -m set --match-set REDISLIST src -j ACCEPT
    sudo iptables -I INPUT -m state --state NEW -p tcp --dport $MYSQL_PORT -m set --match-set MYSQLLIST src -j ACCEPT
    sudo iptables -I INPUT -m state --state NEW -p tcp --dport $ZABBIX_PORT -m set --match-set ZABBIXLIST src -j ACCEPT
    sudo iptables -I INPUT -m state --state NEW -p tcp --dport $JENKINS_PORT -m set --match-set JENKINSLIST src -j ACCEPT
    sudo iptables -I INPUT -m state --state NEW -p tcp -m multiport --dports $RABBITMQ_PORT -m set --match-set RABBITMQLIST src -j ACCEPT
    sudo iptables -I INPUT -m state --state NEW -p tcp -m multiport --dports $MONGODB_PORT -m set --match-set MONGODBLIST src -j ACCEPT
    sudo iptables -I INPUT -m state --state NEW -p tcp -m multiport --dports $NODE_PORT -m set --match-set NODELIST src -j ACCEPT

    # open http
    if [ "$ALLOW_HTTP_OPENED" = "1" ]; then
        sudo echo "ALLOW_HTTP_OPENED: NONE STRICT MODE!"
        sudo iptables -I INPUT -m state --state NEW -p tcp -m multiport --dports $HTTP_PORT -j ACCEPT
    else
        sudo echo "ALLOW_HTTP_OPENED: STRICT MODE!"
        sudo iptables -I INPUT -m state --state NEW -p tcp -m multiport --dports $HTTP_PORT -m set --match-set WHITELIST src -j ACCEPT
    fi

    # drop
    sudo iptables -A INPUT -m limit --limit 1/s -j LOG --log-prefix "[IPTABLES DROP INPUT] : " --log-level=debug
    sudo iptables -A INPUT -j DROP

    # iptables restart
    sudo service iptables save
    sudo service iptables restart
    sudo chkconfig iptables on

    # disable ipv6
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 > /dev/null
    sudo sed -i '/# Disable IPV6/d' /etc/sysctl.conf
    sudo sed -i '/net.ipv6.conf.all.disable_ipv6=1/d' /etc/sysctl.conf
    sudo sed -i '/net.ipv6.conf.default.disable_ipv6=1/d' /etc/sysctl.conf
    sudo echo "# Disable IPV6" >> /etc/sysctl.conf
    sudo echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
    sudo echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf

    # disabled ipv6
    sudo chkconfig ip6tables off
    sudo service ip6tables stop

    # smurf
    sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 > /dev/null
    sudo sed -i '/# Disable Broadcast Ping/d' /etc/sysctl.conf
    sudo sed -i '/net.ipv4.icmp_echo_ignore_broadcasts/d' /etc/sysctl.conf
    sudo echo "# Disable Broadcast Ping" >> /etc/sysctl.conf
    sudo echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> /etc/sysctl.conf

    # syn flood
    sudo sysctl -w net.ipv4.tcp_syncookies=1 > /dev/null
    sudo sed -i '/# Enable SYN Cookie/d' /etc/sysctl.conf
    sudo sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf

    sudo echo "# Enable SYN Cookie" >> /etc/sysctl.conf
    sudo echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf

    # reflect sysctl
    sudo sysctl -p
fi

# show message
sudo echo "IPSET COMPLETE"
#################################################################################
exit 0
#################################################################################
