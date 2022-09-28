# IPSET V3.0.1

this is a script for generating firewall( `iptables` and `ipset` ) rules.

## REQUIREMENT

* `ipset`
* `iptables`
* `git v.2.x`

### HOW TO INSTALL IPSET

you can install via `yum`, try this.

```[bash]
sudo yum -y install ipset
```

### HOW TO UPDATE GIT VERSION

try this.

```[bash]
# FOR CENTOS 6.x
sudo yum -y install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
sudo yum -y install git

# FOR CENTOS 7.x
sudo yum -y remove git
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install git2u
sudo yum-config-manager --disable ius

# git --version   # ===> 2.x
```

## COMPATIBLE FOR

* `CENTOS 6.x`
* `CENTOS 7.x` ===> need to disabled `firewalld`


### HOW TO DISABLED FIREWALLD(CENTOS 7)

```[bash]
# DISABLED FIREWALLD
sudo systemctl stop firewalld.service
sudo systemctl stop firewalld.service
sudo systemctl mask firewalld.service
sudo systemctl list-unit-files | grep firewalld
# firewalld.service                           masked

# INSTALL IPTABLES
sudo yum -y install iptables-services
sudo systemctl start iptables.service
sudo systemctl enable iptables.service
sudo systemctl list-unit-files | grep iptables
# iptables.service                            enabled

# INSTALL IP6TABLES
#sudo systemctl start ip6tables.service
#sudo systemctl enable ip6tables.service
#sudo systemctl list-unit-files | grep ip6tables
# ip6tables.service                           enabled

# DISABLED IPV6
sudo chkconfig ip6tables off
sudo service ip6tables stop
```


## SUMMARY

* `ipset.sh` => this is main script

* `config.sh` => configure `ipset.sh` to run.

* `test.sh` => check `ssh` port.

* `animation.sh` => just do animation as loading...

* `init.sh` => install script.

## SETUP

run the following at `/root` diredtory with super user.

```[bash]
# REMOVE OLD FILES
sudo rm -rf /root/ipset

# GET FROM GIT
cd /root/
git clone https://ryohei-izumi-123@github.com/ryohei-izumi-123/ipset.git

# CHANGE SCRIPT PERMISSION(INIT)
sudo chmod +x /root/ipset/init.sh

# RUN INIT SCRIPT
/root/ipset/init.sh

# RUN MAIN SCRIPT TO SET FIREWALL(IF NO ERROR ON INIT)
/root/ipset/ipset.sh

# IF YOU DONT NEED COUNTRY FILTER FOR HTTPD, PLEASE SPECIFY ARGS
/root/ipset/ipset.sh 1
```


### CONFIG FILES

* config dir is `/root/ipset/`

* `/root/ipset/allow_ssh` is config file for `SSH` to allow connect

* `/root/ipset/allow_ip` is config file for `HTTP/HTTPS` to allow access.

* `/root/ipset/deny_ip` is config file for `HTTP/HTTPS` to deny access.

* `/root/ipset/allow_country` is config file for `HTTP/HTTPS` to allow access by filtering `COUNTRY CODE`, e.g.) `JP` .

* `/root/ipset/deny_country` is config file for `HTTP/HTTPS` to deny access by filtering `COUNTRY CODE`, e.g.) `CN` .

* `/root/ipset/allow_zabbix` is config file for `ZABBIX`.

* `/root/ipset/allow_mysqi` is config file for `MYSQL` to allow connect.

* `/root/ipset/allow_redis` is config file for `REDIS` to allow connect.

* `/root/ipset/allow_node` is config file for `NODE/NPM` to allow access.

* `/root/ipset/allow_jenkins` is config file for `JENKINS` to allow access.

* `/root/ipset/allow_rabbitmq` is config file for `RABBITMQ` to allow access.

### UPDATE

```[bash]

# NEWLY INSTALL
# git clone https://ryohei-izumi-123@github.com/ryohei-izumi-123/ipset.git

# OR UPDATE MODULE
cd /root/ipset
git stash
git pull
/root/ipset/config.sh
# ONLY COPY FILE
# \cp -f allow_ip.ini allow_ip
/root/ipset/ipset.sh 1
```

### CRONTAB

```[bash]
# THIS IS AN EXAMPLE FOR `cron`
# RUN ONCE IN A WEEK
00 10 * * 1 /root/ipset/ipset.sh
# RUN WHEN AFTER REBOOTED
@reboot /root/ipset/ipset.sh
```

**you must set `chkconfig crond on` also**

### UPDATE

```[bash]
sudo -i
cd /root/ipset/
git config --global user.email "XXX"
git config --global user.name "XXX"
git stash
git pull
./config.sh
./ipset.sh
```
