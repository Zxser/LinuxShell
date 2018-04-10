1.
 mysql -uroot -S /data/3306/mysql.sock 


grant replication slave on *.* to 'rep'@'172.16.1.%' identified by 'rep';
flush privileges;

mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000001 |      329 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)

mysqldump -S /data/3306/mysql.sock -A -B --events --master-data=1 > bak.sql


mysql -S /data/3307/mysql.sock  < bak.sql 
mysql -S /data/3307/mysql.sock
create table test.test (`id` int(3) NOT NULL auto_increment, `name` varchar(30)  NOT NULL ,PRIMARY KEY (`id`))ENGINE=InnoDB;

CHANGE MASTER TO
MASTER_HOST='172.16.1.51',
MASTER_USER='rep',
MASTER_PASSWORD='rep',
MASTER_PORT=3306,
MASTER_CONNECT_RETRY=10;
start slave;
show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.16.1.51
                  Master_User: rep
                  Master_Port: 3306
                Connect_Retry: 10
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 329
               Relay_Log_File: relay-bin.000002
                Relay_Log_Pos: 475
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: mysql
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 329
              Relay_Log_Space: 625
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
1 row in set (0.00 sec)

mysql -S /data/3306/mysql.sock
create table test.test (`id` int(3) NOT NULL auto_increment, `name` varchar(30)  NOT NULL ,PRIMARY KEY (`id`))ENGINE=InnoDB;


mysql -S /data/3307/mysql.sock
insert into test.test values (1,'xiaohou');
mysql -S /data/3306/mysql.sock
insert into test.test values (1,'xiaohou');

SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;

[root@db01 data]# cat check_mysql.sh
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-13 23:01
# Email        : houshiying@vip.qq.com
# Filename     : check_mysql.sh
# Description  : 
# ******************************************************

while true;do
    Check_stat=`mysql -S /data/3307/mysql.sock -e "show slave status\G"`
    if echo "$Check_stat"|egrep 'Slave_IO_Running: Yes' &> /dev/null;then
        if echo "$Check_stat"|egrep 'Slave_SQL_Running: Yes'&> /dev/null;then
          if echo "$Check_stat"|egrep 'Seconds_Behind_Master: 0'&> /dev/null;then
            echo "ok"
          else
            echo "yanchi"
          fi
        else
          echo "sql no"
          Error=$(echo "$Check_stat"|grep -Po '(?<=Last_Errno: )\d+')
             Error_id=(1158 1159 1008 1007 1062)
             for i in ${Error_id[@]};do
               if [ $Error -eq $i ];then
                 mysql -S /data/3307/mysql.sock -e "stop slave;"
                 mysql -S /data/3307/mysql.sock -e "SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;"
                 mysql -S /data/3307/mysql.sock -e "start slave;"
               fi
             done
        fi
    else
      echo "io no"
    fi
 sleep 30
done
-----------------------------------------------------------------------------------------------------------------
[root@db01 data]# cat check_mysql.sh
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-13 23:01
# Email        : houshiying@vip.qq.com
# Filename     : check_mysql.sh
# Description  : 
# ******************************************************
repair_err(){
 Error=$(echo "$Check_stat"|grep -Po '(?<=Last_Errno: )\d+')
             Error_id=(1158 1159 1008 1007 1062)
             for i in ${Error_id[@]};do
               if [ $Error -eq $i ];then
                 mysql -S /data/3307/mysql.sock -e "stop slave;"
                 mysql -S /data/3307/mysql.sock -e "SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;"
                 mysql -S /data/3307/mysql.sock -e "start slave;"
               fi
             done
}

check_delay(){
  if echo "$Check_stat"|egrep 'Seconds_Behind_Master: 0'&> /dev/null;then
     echo "ok"
  else
     echo "yanchi"
  fi  
}
check_sql(){
 if echo "$Check_stat"|egrep 'Slave_SQL_Running: Yes'&> /dev/null;then
    check_delay
 else
    echo "sql no"
    repair_err
 fi
}
check_io(){
  if echo "$Check_stat"|egrep 'Slave_IO_Running: Yes' &> /dev/null;then
    check_sql
  else
    echo "io no"
  fi
}
main(){
while true;do
    Check_stat=`mysql -S /data/3307/mysql.sock -e "show slave status\G"`
    check_io
 sleep 30
done
}
main
----------------------
2.[root@db01 ~]# cat touchfile.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 00:37
# Email        : houshiying@vip.qq.com
# Filename     : touchfile.sh
# Description  : 
# ******************************************************

DIR=/oldboy
if [ ! -d $DIR ];then
  mkdir $DIR
fi
for ((i=1;i<=10;i++));do
   a=$(tr -cd "a-z" < /dev/urandom|head -c 10)
   touch $DIR/${a}_oldboy.html
done
----------------
3.
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 09:51
# Email        : houshiying@vip.qq.com
# Filename     : replice.sh
# Description  : 
# ******************************************************
for i in $(ls /oldboy);do
  echo "$i"|sed -r 's@(.*)_oldboy.html@mv & \1_oldgirl.HTML@g'|bash
done

-------------------
4.
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 09:57
# Email        : houshiying@vip.qq.com
# Filename     : useradd.sh
# Description  : 
# ******************************************************
for i in $(seq 1 10);do
 PASS=$(echo "$RANDOM"|md5sum|head -c 8)
 if ! id -u oldboy$i &> /dev/null;then
   useradd $(echo "oldboy$i"|tee -a /tmp/userlist)
   echo "$PASS"|tee -a  /tmp/userlist|passwd --stdin oldboy$i &> /dev/null
 fi
done
------------------------
5. 
[root@db01 ~]# vim ping.sh

#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 10:10
# Email        : houshiying@vip.qq.com
# Filename     : ping.sh
# Description  : 
# ******************************************************
trap "exit 1" INT
IP=10.0.0.
for i in `seq 1 254`;do
  if ping -c1 -w1 $IP$i &> /dev/null;then
    echo -e "\033[32m online.\033[0m"
     else
    echo -e "\033[31m offline. \033[0m"
  fi
done
-----------
6.
[root@db01 ~]# cat ddos.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 10:32
# Email        : houshiying@vip.qq.com
# Filename     : ddos.sh
# Description  : 
# ******************************************************
while true;do
check=$(netstat -tan|awk -F"[ :]+" '$(NF-1)=="ESTABLISHED"{a[$6]++}END{for (i in a)print i,a[i]}')
gt100=$(echo "$check"|awk '{if($2>1) print $1}'|xargs)
   for i in ${gt100[@]};do
     if ! iptables -L -n|grep $i &> /dev/null ;then
       iptables -I INPUT -s $i -j DROP
     fi
   done
 sleep 180
done



------------------
7.

#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 10:49
# Email        : houshiying@vip.qq.com
# Filename     : mysql.sh
# Description  : 
# ******************************************************
port=3306


case $1 in
start)
mysqld_safe --defaults-file=/data/$port/my.cnf &> /dev/null & ;;
stop)
mysqladmin  -S /data/$port/mysql.sock shutdown &> /dev/null;;
restart)
if lsof -i :$port &> /dev/null;then
mysqladmin  -S /data/$port/mysql.sock shutdown  &> /dev/null
fi
mysqld_safe --defaults-file=/data/$port/my.cnf &> /dev/null &;;
*)
echo "usage `basename $0` {start|stop|restart}";;
esac

------------------------------------------
8.
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 10:57
# Email        : houshiying@vip.qq.com
# Filename     : fenku.sh
# Description  : 
# ******************************************************
db=$(mysql -S /data/3306/mysql.sock  -e "show databases;"|grep -vE "Database|information_schema|performance_schema|mysql"|xargs)
for i in ${db[@]};do
  mysqldump -S /data/3306/mysql.sock -B $i > $i.sql
done

-------------------------------
9.

CREATE TABLE test.test1 (
`id` int(3) NOT NULL AUTO_INCREMENT,
`name` varchar(30) NOT NULL,
PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 10:57
# Email        : houshiying@vip.qq.com
# Filename     : fenku.sh
# Description  : 
# ******************************************************
db=$(mysql -S /data/3306/mysql.sock  -e "show databases;"|grep -vE "Database|information_schema|performance_schema|mysql"|xargs)
for i in ${db[@]};do
  table=$(mysql -S /data/3306/mysql.sock  -e "use $i;show tables;"|grep -v "Tables_in"|xargs)
      for j in ${table[@]};do
       mysqldump -S /data/3306/mysql.sock $i $j > ${i}_${j}.sql
      done
done


-----------------------------
10.
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 11:20
# Email        : houshiying@vip.qq.com
# Filename     : 10.sh
# Description  : 
# ******************************************************
a=(I am oldboy teacher welcome to oldboy training class)

for i in  ${a[@]};do
   if [ ${#i} -le  6 ];then
   echo $i
   fi
done

#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 11:22
# Email        : houshiying@vip.qq.com
# Filename     : 10_2.sh
# Description  : 
# ******************************************************
echo "I am oldboy teacher welcome to oldboy training class"|awk '{for (i=1;i<=NF;i++)if (length($i)<=6)print $i}'

------------
11.
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 11:26
# Email        : houshiying@vip.qq.com
# Filename     : 11.sh
# Description  : 
# ******************************************************
until [[ "$a" =~ [0-9]+ ]]&&[[ "$b" =~ ^[0-9]+$ ]];do
read -p "please enter two number:" a b
done
if [ $a -eq $b ];then
  echo "$a = $b"
  elif [ $a -gt $b ];then
  echo "$a > $b"
  else
  echo "$a < $b"
fi

#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 11:26
# Email        : houshiying@vip.qq.com
# Filename     : 11.sh
# Description  : 
# ******************************************************

if  [[ "$1" =~ [0-9]+ ]]&&[[ "$2" =~ ^[0-9]+$ ]];then
   if [ $1 -eq $2 ];then
     echo "$1 = $2"
     elif [ $1 -gt $2 ];then
     echo "$1 > $2"
     else
     echo "$1 < $2"
   fi
fi

----------------------
12。
[root@db01 ~]# cat installweb.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 00:17
# Email        : houshiying@vip.qq.com
# Filename     : lnmp.sh
# Description  : 
# ******************************************************
clear
cat <<EOF
    1.[install lamp]

    2.[install lnmp]

    3.[exit]
EOF
a=0
until [ $a -eq 3 ];do
   read -p "pls input the num you want:" a
     case $a in 
       1)
        echo "startinstalling lamp."
        if [ -f  /root/lamp.sh -a -x /root/lamp.sh ];then
        /root/lamp.sh
        fi;;
       2)
        echo "startinstalling lnmp."
        if [ -f  /root/lnmp.sh -a -x /root/lnmp.sh ];then
        /root/lnmp.sh
        fi;;
       3)
        exit 0
     esac
done

--------------------
13.
ss -tan
lsof -i :80
ps aux|grep httd

ss -tan
lsof -i :3306
ps aux|grep mysql

#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 11:44
# Email        : houshiying@vip.qq.com
# Filename     : 13.sh
# Description  : 
# ******************************************************

while true;do
   if lsof -i :80 &> /dev/null;then
   echo "ok"
   else
   echo "not run."
   fi
 sleep 60
done
-------------------

14.
1）存储数据：printf "set key 0 10 4\r\nkaka\r\n" |nc 127.0.0.1 11211
2）获取数据：printf "get key\r\n" |nc 127.0.0.1 11211
3）删除数据：printf "delete key\r\n" |nc 127.0.0.1 11211
4）查看状态：printf "stats\r\n" |nc 127.0.0.1 11211

----------------------
15.
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 11:56
# Email        : houshiying@vip.qq.com
# Filename     : 15.sh
# Description  : 
# ******************************************************
find /data/ -type f|xargs md5sum > /tmp/check.txt
while true;do
    echo "md5sum -c /tmp/check.txt |grep -v 'OK'"
   sleep 180
done
--------------------------------
16.
[root@db01 ~]# cat 16.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 12:04
# Email        : houshiying@vip.qq.com
# Filename     : 16.sh
# Description  : 
# *****************************************************
#chkconfig 2345  57 80

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

RETVAL=0
prog="rsync"
lockfile=/var/lock/subsys/$prog
pidfile=/var/run/rsync/pid/${prog}.pid

conf_rsync() {
if ! [ -f /etc/rsyncd.conf -a -f /etc/rsync.password ];then
cat > /etc/rsyncd.conf << EOF
uid = nobody
gid = nobody
use chroot = no
max connections = 10
use chroot = no
max connections = 10
strict modes = yes
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
timeout = 300
[data]
path = /data
ignore errors = yes
read only = no
write only = no
hosts allow = 172.16.1.0/24
hosts deny = *
list = false
auth users= rsync
secrets file= /etc/rsync.password
EOF
cat > /etc/rsync.password <<EOF
rsync:rsync
EOF
chmod 600 /etc/rsync.password 
fi
}


        
        
start() {
        [ "$EUID" != "0" ] && exit 4
        conf_rsync
        echo -n $"Starting $prog: "
        daemon $prog --daemon
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch $lockfile
        echo
        return $RETVAL
}


stop() {
        [ "$EUID" != "0" ] && exit 4
        echo -n $"Shutting down $prog: "
        killproc $prog
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f /etc/rsyncd.conf /etc/rsync.password  && rm -f $lockfile
        return $RETVAL
}



case $1 in 
start)
   conf_rsync
   start;;
stop)
   stop;;
restart)
   stop
   start;;
*)
  echo $"Usage: $0 {start|stop|restart}"
esac
------------------------
17.
[root@db01 ~]# cat 17.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 15:50
# Email        : houshiying@vip.qq.com
# Filename     : 17.sh
# Description  : 
# ******************************************************
namedb=/tmp/name.db
> $namedb
cat <<EOF
enter name
enter quit
EOF
while [[ "$name" != 'quit' ]];do
 read -p "please enter your name:" name
   if  [[ "$name" != 'quit' ]];then
     if grep "$name" $namedb &> /dev/null ;then
       echo "user exists."
     else
       num=$(($RANDOM%100))
         while grep "$num" $namedb &> /dev/null ;do
           num=$(($RANDOM%100))
         done
       echo "$name $num"|tee -a $namedb
     fi
   fi
done
sort -k2,2rn $namedb|head -3
-------------------------------
18.
[root@db01 ~]# cat 18.sh
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 16:23
# Email        : houshiying@vip.qq.com
# Filename     : 18.sh
# Description  : 
# ******************************************************
a=(21029299 00205d1c a3da1677 1f6d12dd 890684b)
for i in ${a[@]};do
  for ((j=0;j<=32767;j++));do
      b=$(echo $j|md5sum|cut -c 1-8)
    if [[ "$b" == $i ]];then
      echo "$j $b"
    fi
  done
done
---------------------
19.
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 16:51
# Email        : houshiying@vip.qq.com
# Filename     : 19.sh
# Description  : 
# ******************************************************
a=(http://www.etiantian.org
http://www.taobao.com
http://oldboy.blog.51cto.com
http://10.0.0.7
)
for i in ${a[@]};do
  if  curl -I $i &> /dev/null;then
   echo "$i ok"
  else
   echo "$i failed"
  fi
done
------------------------
20.[root@db01 ~]# cat 20.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 16:54
# Email        : houshiying@vip.qq.com
# Filename     : 20.sh
# Description  : 
# ******************************************************
a='the squid project provides a number of resources toassist users design,implement and support squid installations. Please browsethe documentation and support sections for more infomation'

echo "sort 1:"
echo $a|awk '{for(i=1;i<=NF;i++)a[$i]++}END{for (j in a)print j,a[j]}'|sort -k2,2rn

echo "sort 2:"
echo $a|sed -r 's@[[:space:],\.]@@g'|awk -v FS="" '{for(i=1;i<=NF;i++)a[$i]++}END{for (j in a)print j,a[j]}'|sort -k2,2rn


-------------------------
21.
[root@db01 ~]# cat 21_1.sh
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 17:22
# Email        : houshiying@vip.qq.com
# Filename     : 21_1.sh
# Description  : 
# ******************************************************
read -p "please enter a num:" a
for i in `seq 1 $a`;do
     for j in `seq 1 $a`;do
       echo -n "+"
    done
  echo 
done

[root@db01 ~]# cat 21_2.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 17:28
# Email        : houshiying@vip.qq.com
# Filename     : 21_2.sh
# Description  : 
# ******************************************************
read -p "pls enter a num:" a
for ((i=1;i<=a;i++));do
    for ((j=a-1;j>=i;j--));do
       echo -ne " "
     done
     for ((k=1;k<=(2*i-1);k++));do
        echo -ne  "+" 
     done
  echo
done

[root@db01 ~]# cat 21_3.sh 
#!/usr/bin/env bash
# ******************************************************
# Author       : xiaohou
# Last modified: 2016-09-14 17:28
# Email        : houshiying@vip.qq.com
# Filename     : 21_2.sh
# Description  : 
# ******************************************************
read -p "pls enter two num:" a b
for ((i=a;i<=b;i++));do
     for ((k=0;k<i;k++));do
        echo -n  "+" 
     done
  echo
done


----------------------------------

22.测试web页面

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Nginx http upstream check status</title>
</head>
<body background="bg.jpg" align="center">
</br>
</br>
<h1>Nginx http upstream check status</h1>
</br>
</br>
</br>
</br>
<table style="background-color:#90FF90" cellspacing="0"    align="center"    cellpadding="3" border="1">
  <tr bgcolor="#C0C0C0">
    <th>Index</th>
    <th>Upstream</th>
    <th>Name</th>
    <th>Status</th>
  </tr>
  <tr bgcolor="#FF0000"> <!--10.0.0.7-->
    <td>0</td>
    <td>web02</td>
    <td>10.0.0.7:80</td>
    <td>down</td> <!--10.0.0.7-->
  </tr>
  <tr>   <!--10.0.0.8-->
    <td>1</td>
    <td>web01</td>
    <td>10.0.0.8:80</td>
    <td>up</td> <!--10.0.0.8-->
  </tr>
</table>
</body>
</html>


#!/bin/bash

web=("10.0.0.8" "10.0.0.7")
file=/usr/local/nginx/html/index.html
while true;do
for i in ${web[@]};do
if curl -I $i &> /dev/null;then
  if ! grep  "<tr> <!--${i}-->" $file &> /dev/null ;then
    sed -ri "s@(<tr).*(<!--${i}-->)@\1> \2@g" $file
    sed -ri "s@(<td>).*(</td> <!--${i}-->)@\1up\2@g" $file
  fi
else
  if ! grep "<tr bgcolor='#FF0000'> <!--${i}-->" $file &> /dev/null ;then
    sed -ri "s@(<tr).*(<!--${i}-->)@\1 bgcolor='#FF0000'> \2@g" $file
    sed -ri "s@(<td>).*(</td> <!--${i}-->)@\1down\2@g" $file
  fi
fi
done
sleep 3
done
----------------------------------------
23 .手工开发ipvsadm管理lvs的脚本ip_vs 实现：/etc/init.d/lvs {start|stop|restart|status}
[root@lb02 ~]# cat /etc/init.d/ipvsadm 
#!/bin/bash
# date: 2016.8.22
# chkconfig: 2345 28 72
# description: start up  the Linux Virtual Server
# author:

# Source function library
. /etc/rc.d/init.d/functions


VIP=10.0.0.3
RIP[0]="10.0.0.7"
RIP[1]="10.0.0.8"
Lockfile=/var/lock/subsys/ipvsadm

# start the lvs
ipvs_start(){
   init_lvs
   ip addr add ${VIP}/24 dev eth0 label eth0:1
   ipvsadm -C
   ipvsadm -A -t ${VIP}:80 -s rr -p 20
   add_rs
   touch $Lockfile
}
# Add Real Server to LVS
add_rs(){
for i in ${RIP[*]};do
   ipvsadm -a -t ${VIP}:80 -r ${i}:80 -g
done
}
# stop the lvs
ipvs_stop(){
   ip addr del ${VIP}/24 dev eth0 label eth0:1
   ipvsadm -C
   rm -f $Lockfile
}

# ipvs state
ipvs_status(){
  if [ -f $Lockfile ];then
     ipvsadm -L -n
  else
     echo "ipvs is not running"
     return 1
  fi    
}
# initial the lvs after installed lvs
init_lvs(){
if ! lsmod |grep ip_vs &> /dev/null;then
modprobe ip_vs
fi
}

#  judge the command result
res_start(){
    if [ -f $Lockfile ];then
      echo  "the ipvs is started."
  else
      if ipvs_start ;then
         action "the ipvs start is" /bin/true
      else
         action "the ipvs start is" /bin/false
     fi
  fi
}
res_stop(){
 if [ -f $Lockfile ];then
      if ipvs_stop;then
           action "the ipvs stoped is"  /bin/true
      else
           action "the ipvs stoped is" /bin/false
      fi
  else
      echo  "ipvs is not running"
  fi
}
res_restart(){
   if [ -f $Lockfile ];then
     ipvs_stop && action "ipvs stop" /bin/true ||\
     action "ipvs stop"  /bin/false
     ipvs_start && action "ipvs start" /bin/true||\
     action "ipvs start"  /bin/false
   else
     ipvs_start && action "ipvs start" /bin/true||\
     action "ipvs start"  /bin/false
   fi
}

case $1 in 
start)
  res_start;;
stop)
  res_stop;;
status)
   ipvs_status ;;
restart)
 res_restart ;; 
*)
   echo "Usage `basename $0` {start|stop|status|resstart}";;
esac

-------------------------------------
24【LVS主节点】模拟keepalived健康检查功能管理LVS节点，
当节点挂掉（检测2次，间隔2秒）从服务器池中剔除，好了（检测2次，间隔2秒）加进来
[root@lb02 ~]# cat ipvshealth.sh 
#!/bin/bash
# date: 2016.8.22
# 
# description: check health  the Linux Virtual Server
# author:

i=0
VIP=10.0.0.3
RIP[0]="10.0.0.7"
RIP[1]="10.0.0.8"
#add real server
add_rs(){
 ipvsadm -a -t $VIP:80 -r $i:80 -g
}
#del real server
del_rs(){
 ipvsadm -d -t $VIP:80 -r $i:80 
}
# check real server state
x=0
chk_rs(){
while true;do
   for i in ${RIP[*]} ;do
      while [ $x -lt 2 ];do
        a=$(curl -s -o /dev/null -I -w "%{http_code}\n" http://${i})
        let x++
      done
        x=0
        if [ $a -eq 200 ];then
           if ! ipvsadm -Ln|grep $i &> /dev/null ;then
              add_rs
           fi
        else 
           if  ipvsadm -Ln|grep $i &> /dev/null ;then
              del_rs
           fi
        fi
   done
   sleep 2
done
}    
chk_rs
--------------------------------------
25.

【LVS客户端节点】开发LVS客户端设置VIP以及抑制ARP的管理脚本
    实现：/etc/init.d/lvsclient {start|stop|restart}

[root@web01 ~]# cat /etc/init.d/lvs_client 
#!/bin/bash
# date: 2016.8.22
# chkconfig: 2345 30 73
# description: start up  the Linux Virtual Server
# author:

# Source function library
. /etc/rc.d/init.d/functions


VIP=10.0.0.3
LOCK_FILE=/var/lock/subsys/lvs_client
rs_start(){
  echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
  echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
  echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
  echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce   
  ip addr add $VIP/32 dev lo label lo:0
  touch  $LOCK_FILE
}
rs_stop(){
   echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
   echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
   echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
   echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
   ip addr del $VIP/32 dev lo label lo:0
   rm -f $LOCK_FILE
}

case $1 in 
start) 
  [ -f $LOCK_FILE ]&& echo "lvs-client is started." && exit 0
  rs_start && action "lvs-client start is" /bin/true||\
  action "lvs-client start is" /bin/false ;;
stop)
  ! [ -f $LOCK_FILE ]&& echo "lvs-client is stoped." && exit 0
  rs_stop && action "lvs-client stop is" /bin/true||\
  action "lvs-client stop is" /bin/false ;;
restart)
  if  ! [ -f $LOCK_FILE ];then
     if rs_start;then
       action "lvs-client start is" /bin/true
     else
       action "lvs-client start is" /bin/false
     fi
  else
     if rs_stop;then
      action "lvs-client stop is" /bin/true
     else 
      action "lvs-client stop is" /bin/false
     fi
  
     if rs_start;then
       action "lvs-client start is" /bin/true
     else
       action "lvs-client start is" /bin/false
     fi
  fi ;;
*)
  echo "Usage: `basename $0` {start|stop|restart}"
esac
------------------------------------------------------------

26、【LVS备节点】模拟keepalved vrrp功能，监听主节点，如果主节点不可访问则备节点启动并配置LVS实现接管主节点的资源提供服务（提醒：注意ARP缓存）

[root@lb02 ~]# cat  ipvs_ipcheck.sh 
#!/bin/bash

VIP=10.0.0.3
MASTER=10.0.0.5
BACKUP=10.0.0.6
GATEWAY=10.0.0.2

while true;do
    if ping -c 1 -w 1 $MASTER  &> /dev/null &&\
       arping -c 1 -f -D $VIP |grep "1 response(s)" &> /dev/null ;then
             if /etc/init.d/ipvsadm status &> /dev/null ;then
                /etc/init.d/ipvsadm stop &> /dev/null
             fi
    else
          if ! /etc/init.d/ipvsadm status &> /dev/null;then
          /etc/init.d/ipvsadm start &> /dev/null
          arping -c 1 -U -I eth0:1 -s $VIP $GATEWAY
          fi
    fi 
    sleep 1
done
-----------------------------------

