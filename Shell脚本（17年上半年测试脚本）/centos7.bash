#!/bin/bash
#filename:post-install-setup.sh
####################请根据需要修改以下变量的值######################
HostName="centos7"
NET_IF_NAME="ens33"
NET_ipv4.addr="192.168.136.4/24"
NET_ipv4.gateway="192.168.136.1/24"
NET_ipv4.dns="8.8.8.8 1.2.4.8"
Centos_MIRROR="mirrors.sohu.com"
EPEL_MIRROR="mirrors.yun-ide.com"
NTP_SERVER="pool.ntp.org"
###################################################################
#配置root用户环境
echo "alias ping='ping -c 4'" >> /root/.bashrc
echo "alias cls='clear'" >> /root/.bashrc
echo "alias cd..='cd ..'" >> /root/.bashrc
echo 'export HISTSIZE=100' >> /root/.bash_profile
echo 'export HISTIGNORE=ls:ll' >> /root/.bash_profile
echo 'export HISTCONTROL=ignoreboth' >> /root/.bash_profile
#设置主机名和网络
hostnamectl set-hostname $HOSTName
nmcli conn mod $NET_IF_NAME ipv4.method manual \
ipv4.addr $NET_ipv4.addr ipv4.geteway $NET_ipv4.gateway ipv4.dns $NET_ipv4.dns
nmcli dev disc $NET_IF_NAME
nmcli conn up $NET_IF_NAME
#配置yum仓库
yum -y install epel-release
rpm  --import /etc/pki/rpm-gpg/RPM-GPG-KEY-*
cp /etc/yum.repos.d/CentOS-Base.repo{,.$(date +'%F_%T')}
sed -i "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOs-Base.repo
sed -i "s/^#baseurl/#baseurl/g" /etc/yum.repos.d/CentOs-Base.repo
sed -i "s/mirror.centos.org/#CentOs_MIRROR/g" /etc/yum.repos.d/CentOs-Base.repo









#!/bin/bash
COUNTER=0
_R=0
_C=`tput cols`
_PROCEC=`tput cols`
tput cup $_C $_R
printf "["
while [ $COUNTER -lt 100 ]
do
    COUNTER=`expr $COUNTER + 1`
    sleep 0.1
    printf "=>"
    _R=`expr $_R + 1`
    _C=`expr $_C + 1`
    tput cup $_PROCEC 101
    printf "]%\n"



#!/bin/bash
i=0
while [$i -lt 20]
do
     ((i++))
     echo   -ne "=>\033[s"
     echo -ne    "\033[40;50H"$((i*5*100/100))]"