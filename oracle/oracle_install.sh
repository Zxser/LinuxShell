#!/bin/bash
#Author:daya  			#Release: 1.0
#Function:auto install oracle
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:~/bin
export PATH
declare -a SOFT
SOFT[0]="p10404530_112030_Linux-x86-64_1of7.zip"
SOFT[1]="p10404530_112030_Linux-x86-64_2of7.zip"
SOFT[2]="pdksh-5.2.14-36.el5.x86_64.rpm"
SOFT[3]="rlwrap-0.37.tar.gz"
function check_yum (){
yum remove -y elinks >/dev/null 2>&1
yum install -y elinks >/dev/null 2>&1
rpm -q elinks >/dev/null 2>&1
[ $? -eq 0 ] || exit 1 
[ "`uname -r |awk 'BEGIN{FS="."}{print $NF}'`" == "x86_64" ] && [ `awk 'BEGIN{FS="[ .]+"}NR==1{print $7}' /etc/issue` -eq 6 ] || exit 2
}
check_yum
function check_user (){
egrep -q "^oinstall" /etc/group
[ $? -ne 0 ] && groupadd oinstall 
egrep -q "^dba" /etc/group
[ $? -ne 0 ] && groupadd dba
egrep -q "^oper" /etc/group
[ $? -ne 0 ] && groupadd oper
if ! id oracle >/dev/null 2>&1;then
useradd -g oinstall -G dba,oper oracle && echo "oracle" |passwd --stdin oracle 
else 
useradd -g oinstall -G dba,oper oracle >/dev/null 2>&1
fi
}
check_user
function check_soft (){
yum install -y  gcc* gcc-c++ binutils-* compat* glibc* ksh* libgcc* libstdc* libaio* libaio-devel-* make* sysstat* unixODBC* readline* elfutils-libelf-*
cd ../
[ ! -d /software/db ] && mkdir -p /software/db
cp ${SOFT[*]} /software/db
wait
cd /software/db && unzip ${SOFT[0]}  
wait
unzip ${SOFT[1]} 
wait
[ -d /software/db/database ] && [ "`du -sh /software/db/database/ |awk '{print $1}'`" == "2.5G" ] || exit 4
chown -R oracle:oinstall /software/db/database && chmod 755 -R /software/db/database
cd /software/db && tar -zxvf ${SOFT[3]}
[ -d ${SOFT[3]%%.t*} ] || exit 5
cd ${SOFT[3]%%.t*} && ./configure && make && make install || exit 6
}
check_soft

function check_directory (){
[ ! -d /u01/app/oracle ] && mkdir -p /u01/app/oracle 
chown -R oracle:oinstall /u01 && chmod 755 /u01/app/oracle
}
check_directory

function check_parameter (){
cat >>/etc/hosts<<EOF
#################   oracle_configrue   ############
`ifconfig |awk 'BEGIN{FS="[ :]+"}/Bcast/{print $4}'`	`hostname`
EOF
cat >>/etc/security/limits.conf<<EOF
#################   oracle_configrue   ############
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft stack 10240
EOF
cat >>/etc/etc/sysctl.conf<<EOF
#################   oracle_configrue   ############
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF
sysctl -p >/dev/null 2>&1
cat >>/home/oracle/.bash_profile<<EOF
#################   oracle_configrue   ############
unset TNS_ADMIN
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export ORACLE_SID=PROD
export PATH=/u01/app/oracle/product/11.2.0/dbhome_1/bin:$PATH
EOF
}
check_parameter
su - oracle -c "source /home/oracle/.bash_profile"
sleep 5
rpm -e ksh || yum remove -y ksh
cd /software/db
rpm -i ${SOFT[2]} 
[ $? -eq 0 ] && cd /software/db && rm -rf ${SOFT[@]} && echo -e "\E[40;32;1m Please switch oracle and cd /software/db/database execute runInstaller!\E[0m"

