获取ip
#!/bin/bash
while :
do
     read -p "请输入网卡名: " e
     e1=`echo "$e" | sed 's/[-0-9]//g'`
     e2=`echo "$e" | sed 's/[a-zA-Z]//g'`
     if [ -z $e ]
     then
        echo "你没有输入任何东西"
        continue
     elif [ -z $e1 ]
     then
        echo "不要输入纯数字在centos中网卡名是以eth开头后面加数字"
        continue
     elif [ -z $e2 ]
     then
        echo "不要输入纯字母在centos中网卡名是以eth开头后面加数字"
        continue
     else
        break
     fi
done
ip() {
        ifconfig | grep -A1 "$1 " |tail -1 | awk '{print $2}' | awk -F ":" '{print $2}'
}
myip=`ip $e`
if [ -z $myip ]
then
    echo "抱歉，没有这个网卡。"
else
    echo "你的网卡IP地址是$myip"
fi


列出子目录
#!/bin/bash
if [ $# == 0 ]
then
ls -ld `pwd`
else
for i in `seq 1 $#`
do
a=$i
echo "ls ${!a}"
ls -l ${!a} |grep '^d'
done
fi
#对${!a}有疑问，这里是一个特殊用法，在shell中，$1为第一个参数，$2为第二个参数，
#以此类推，那么这里的数字要是一个变量如何表示呢？比如n=3,我想取第三个参数，
#能否写成 $$n？ shell中是不支持的，那怎么办？ 就用脚本中的这种方法：  a=$n, echo ${!a} 

下载文件 
#!/bin/bash

if [ ! -d $2 ]
then
    echo "please make directory"
    exit 51
fi
cd $2
wget $1
n=`echo $?`
if [ $n -eq 0 ];then
    exit 0
else
    exit 52
fi


猜数字 
#!/bin/bash
m=`echo $RANDOM`
n1=$[$m%100]
while :
do
    read -p "Please input a number: " n
    if [ $n == $n1 ]
    then
        break
    elif [ $n -gt $n1 ]
    then
        echo "bigger"
        continue
    else
        echo "smaller"
        continue
    fi
done
echo "You are right."

日志归档 
#!/bin/bash
function e_df()
{
    [ -f $1 ] && rm -f $1
}

for i in `seq 5 -1 2`
do
    i2=$[$i-1]
    e_df /data/1.log.$i
    if [ -f /data/1.log.$i2 ]
    then
        mv /data/1.log.$i2 /data/1.log.$i
    fi
done

e_df /data/1.log.1
mv /data/1.log  /data/1.log.1


只有一个数字的行 
#!/bin/bash
f=/etc/passwd
line=`wc -l $f|awk '{print $1}'`
for l in `seq 1 $line`; do
     n=`sed -n "$l"p $f|grep -o '[0-9]'|wc -l`;
     if [ $n -eq 1 ]; then
        sed -n "$l"p $f
     fi
done


抽签脚本
while :
do
read -p  "Please input a name:" name
  if [ -f /work/test/1.log ];then
     bb=`cat /work/test/1.log | awk -F: '{print $1}' | grep "$name"`
     if [ "$bb" != "$name" ];then  #名字不重复情况下
        aa=`echo $RANDOM | awk -F "" '{print $2 $3}'`
         while :
          do
       dd=`cat  /work/test/1.log |  awk -F: '{print $2}'  | grep "$aa"`
          if [ "$aa"  ==  "$dd" ];then   #数字已经存在情况下
            echo "数字已存在."
            aa=`echo $RANDOM | awk -F "" '{print $2 $3}'`
           else
            break
          fi
          done
        echo "$name:$aa" | tee -a /work/test/1.log
     else
     aa=`cat /work/test/1.log |  grep "$name" | awk -F: '{print $2}'` #名字重复
       echo $aa
       echo "重复名字."
     fi
  else
      aa=`echo $RANDOM | awk -F "" '{print $2 $3}'`
      echo "$name:$aa" | tee -a  /work/test/1.log
  fi
done

判断是否开启80端口
 #!/bin/bash
 port=`netstat -lnp | grep 80`
 if [ -z "port" ]; then
     echo "not start service.";
     exit;
 fi
 web_server=`echo $port | awk -F'/' '{print $2}'|awk -F : '{print $1}'` 
case $web_server in
   httpd ) 
       echo "apache server."
   ;;
   nginx )
       echo "nginx server."
   ;;
   * )
       echo "other server."
   ;; 
esac
统计网卡流量
#!/bin/bash

while :
do
    LANG=en
    DATE=`date +"%Y-%m-%d %H:%M"`
    LOG_PATH=/tmp/traffic_check/`date +%Y%m`
    LOG_FILE=$LOG_PATH/traffic_check_`date +%d`.log
    [ -d $LOG_PATH ] || mkdir -p $LOG_PATH
    echo " $DATE" >> $LOG_FILE
    sar -n DEV 1 59|grep Average|grep eth0 \ 
    |awk '{print "\n",$2,"\t","input:",$5*1000*8,"bps", \
    "\t","\n",$2,"\t","output:",$6*1000*8,"bps" }' \ 
    >> $LOG_FILE
    echo "#####################" >> $LOG_FILE
done


检测文件改动
#!/bin/bash
#假设A机器到B机器已经做了无密码登录设置
dir=/data/web
##假设B机器的IP为192.168.0.100
B_ip=192.168.0.100
find $dir -type f |xargs md5sum >/tmp/md5.txt
ssh $B_ip "find $dir -type f |xargs md5sum >/tmp/md5_b.txt"
scp $B_ip:/tmp/md5_b.txt /tmp
for f in `awk '{print $2}' /tmp/md5.txt`
do
    if grep -q "$f" /tmp/md5_b.txt
    then
        md5_a=`grep $f /tmp/md5.txt|awk '{print $1}'`
        md5_b=`grep $f /tmp/md5_b.txt|awk '{print $1}'`
        if [ $md5_a != $md5_b ]
        then
             echo "$f changed."
        fi
    else
        echo "$f deleted. "
    fi
done
统计日志大小
#!/bin/bash

logdir="/data/log"
t=`date +%H`
d=`date +%F-%H`
[ -d /tmp/log_size ] || mkdir /tmp/log_size
for log in `find $logdir -type f`
do
    if [ $t == "0" ] || [ $t == "12" ]
    then
    true > $log
    else
    du -sh $log >>/tmp/log_size/$d
    fi
done
统计常用命令
sort /root/.bash_history |uniq -c |sort -nr |head
监控磁盘使用率
#!/bin/bash
## This script is for record Filesystem Use%,IUse% everyday and send alert mail when % is more than 85%.

log=/var/log/disk/`date +%F`.log
date +'%F %T' > $log
df -h >> $log
echo >> $log
df -i >> $log

for i in `df -h|grep -v 'Use%'|sed 's/%//'|awk '{print $5}'`; do
    if [ $i -gt 85 ]; then
        use=`df -h|grep -v 'Use%'|sed 's/%//'|awk '$5=='$i' {print $1,$5}'`
        echo "$use" >> use
    fi
done
if [ -e use ]; then

   ##这里可以使用咱们之前介绍的mail.py发邮件
    mail -s "Filesystem Use% check" root@localhost < use
    rm -rf use
fi

for j in `df -i|grep -v 'IUse%'|sed 's/%//'|awk '{print $5}'`; do
    if [ $j -gt 85 ]; then
        iuse=`df -i|grep -v 'IUse%'|sed 's/%//'|awk '$5=='$j' {print $1,$5}'`
        echo "$iuse" >> iuse
    fi
done
if [ -e iuse ]; then
    mail -s "Filesystem IUse% check" root@localhost < iuse
    rm -rf iuse
fi
思路：
1、df -h、df -i 记录磁盘分区使用率和inode使用率，date +%F 日志名格式
2、取出使用率(第5列)百分比序列，for循环逐一与85比较，大于85则记录到新文件里，当for循环结束后，汇总超过85的一并发送邮件(邮箱服务因未搭建，发送本地root账户)。

此脚本正确运行前提：

该系统没有逻辑卷的情况下使用，因为逻辑卷df -h、df -i 时，使用率百分比是在第4列，而不是第5列。如有逻辑卷，则会漏统计逻辑卷使用情况。



统计普通用户
#!/bin/bash
 n=`awk -F ':' '$3>1000' /etc/passwd|wc -l`
 if [ $n -gt 0 ]
 then
     echo "There are $n common users."
 else
     echo "No common users."
 fi





 需求： 根据web服务器上的访问日志，把一些请求量非常高的ip给拒绝掉！
 #! /bin/bashlogfile=/home/logs/client/access.log
d1=`date -d "-1 minute" +%H:%M`
d2=`date +%M`
ipt=/sbin/iptables
ips=/tmp/ips.txt

block(){
    grep "$d1:" $logfile|awk '{print $1}' |sort -n |uniq -c |sort -n >$ips
    for ip in `awk '$1>50 {print $2}' $ips`; do
        $ipt -I INPUT -p tcp --dport 80 -s $ip -j REJECT
        echo "`date +%F-%T` $ip" >> /tmp/badip.txt
    done
}

unblock(){
    for i in `$ipt -nvL --line-numbers |grep '0.0.0.0/0'|awk '$2<15 {print $1}'|sort -nr`; do
        $ipt -D INPUT $i
    done
    $ipt -Z
}

if [ $d2 == "00" ] || [ $d2 == "30" ]; then
    unblock
    block
else
    block
fi



批量创建用户并设置密码
#!/bin/bash
for i in `seq -w 00 09`
do
useradd user_$i
p=`mkpasswd -s 0 -l 10`
echo “user_$i $p” >>/tmp/user0_9.pass
echo $p |passwd –stdin user_$i
done

备份数据库
#! /bin/bash

### backup mysql data

### Writen by Aming.

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/mysql/bin

d1=`data +%w`

d2=`date +%d`

pass=”your_mysql_password”

bakdir=/bak/mysql

r_bakdir=192.168.123.30::backup

exec 1>/var/log/mysqlbak.log 2>/var/log/mysqlbak.log

echo “mysql backup begin at `date +”%F %T”`.”

mysqldump -uroot -p$pass –default-character-set=gbk discuz >$bakdir/$d1.sql

rsync -az $bakdir/$d1.sql $r_bakdir/$d2.sql

echo “mysql backup end at `date +”%F %T”`.”
然后加入cron

0 3 * * * /bin/bash /usr/local/sbin/mysqlbak.sh





监控80端口
#! /bin/bash
mail=123@123.com
if netstat -lnp |grep ‘:80’ |grep -q ‘LISTEN’; then
exit
else
/usr/local/apache2/bin/apachectl restart >/dev/null 2> /dev/null
python mail.py $mail “check_80” “The 80 port is down.”
n=`ps aux |grep httpd|grep -cv grep`
if [ $n -eq 0 ]; then
/usr/local/apache2/bin/apachectl start 2>/tmp/apache_start.err
fi
if [ -s /tmp/apache_start.err ]; then
python mail.py  $mail  ‘apache_start_error’   `cat /tmp/apache_start.err`
fi
fi


mail.py
#!/usr/bin/env python
#-*- coding: UTF-8 -*-
import os,sys
import getopt
import smtplib
from email.MIMEText import MIMEText
from email.MIMEMultipart import MIMEMultipart
from  subprocess import *

def sendqqmail(username,password,mailfrom,mailto,subject,content):
    gserver = 'smtp.qq.com'
    gport = 25

    try:
        msg = MIMEText(unicode(content).encode('utf-8'))
        msg['from'] = mailfrom
        msg['to'] = mailto
        msg['Reply-To'] = mailfrom
        msg['Subject'] = subject

        smtp = smtplib.SMTP(gserver, gport)
        smtp.set_debuglevel(0)
        smtp.ehlo()
        smtp.login(username,password)

        smtp.sendmail(mailfrom, mailto, msg.as_string())
        smtp.close()
    except Exception,err:
        print "Send mail failed. Error: %s" % err


def main():
    to=sys.argv[1]
    subject=sys.argv[2]
    content=sys.argv[3]
##定义QQ邮箱的账号和密码，你需要修改成你自己的账号和密码（请不要把真实的用户名和密码放到网上公开，否则你会死的很惨）
    sendqqmail('1234567@qq.com','aaaaaaaaaa','1234567@qq.com',to,subject,content)

if __name__ == "__main__":
    main()
    
    
#####脚本使用说明######
#1. 首先定义好脚本中的邮箱账号和密码
#2. 脚本执行命令为：python mail.py 目标邮箱 "邮件主题" "邮件内容"


设计监控脚本
思路：监控远程的一台机器(假设ip为123.23.11.21)的存活状态，当发现宕机时发一封邮件给你自己。

提示：
1. 你可以使用ping命令   ping -c10 123.23.11.21
2. 发邮件脚本可以参考 https://coding.net/u/aminglinux/p/aminglinux-book/git/blob/master/D22Z/mail.py
3. 脚本可以搞成死循环，每隔30s检测一次
#!/bin/bash


批量更改文件名
#!/bin/bash
##查找txt文件
find /123 -type f -name “*.txt” > /tmp/txt.list
##批量修改文件名
for f in `cat /tmp/txt.list`
do
mv $f $f.bak
done
##创建一个目录，为了避免目录已经存在，所以要加一个复杂的后缀名
d=`date +%y%m%d%H%M%S`
mkdir /tmp/123_$d
##把.bak文件拷贝到/tmp/123_$d
for f in `cat /tmp/txt.list`
do
cp $f.bak /tmp/123_$d
done
##打包压缩
cd /tmp/
tar czf 123.tar.gz 123_$d/
##还原
for f in `cat /tmp/txt.list`
do
mv $f.bak $f
done


ip=123.23.11.21
ma=abc@139.com

while 1

do
ping -c10 $ip >/dev/null 2>/dev/null
if [ $? != “0” ];then
python /usr/local/sbin/mail.py $ma “$ip down” “$ip is down”

#假设mail.py已经编写并设置好了
fi
sleep 30
done

统计内存使用
#! /bin/bash

sum=0

for mem in `ps aux |awk ‘{print $6}’ |grep -v ‘RSS’ `

do

sum=$[$sum+$mem]

done

echo “The total memory is $sum””k”
也可以使用awk 一条命令计算：

ps aux | grep -v ‘RSS TTY’ |awk ‘{(sum=sum+$6)};END{print sum}’


统计日志
awk ‘{print $1}’ 1.log |sort -n|uniq -c |sort -n}’ 1.log |sort -n|uniq -c |sort -n


每日生成一个文件
#! /bin/bash
d=`date +%F`
logfile=$d.log
df -h > $logfile


监控mysql服务
#!/bin/bash
Mysql_c="mysql -uroot -p123456"
$Mysql_c -e "show processlist" >/tmp/mysql_pro.log 2>/tmp/mysql_log.err
n=`wc -l /tmp/mysql_log.err|awk '{print $1}'`

if [ $n -gt 0 ]
then
    echo "mysql service sth wrong."
else

    $Mysql_c -e "show slave status\G" >/tmp/mysql_s.log
    n1=`wc -l /tmp/mysql_s.log|awk '{print $1}'`

    if [ $n1 -gt 0 ]
    then
        y1=`grep 'Slave_IO_Running:' /tmp/mysql_s.log|awk -F : '{print $2}'|sed 's/ //g'`
        y2=`grep 'Slave_SQL_Running:' /tmp/mysql_s.log|awk -F : '{print $2}'|sed 's/ //g'`

        if [ $y1 == "Yes" ] && [ $y2 == "Yes" ]
        then
            echo "slave status good."
        else
            echo "slave down."
        fi
    fi
fi








#!/bin/bash
#
#rpm -q python 
#升级python为2.7 注意不要卸载系统自带的python，因为系统自带的好多软件依赖自带的python
dir=/tmp/iPython
file=Python-2.7.8.tar.xz
file2=ipython-2.3.1.tar.gz
num=`rpm -q python|grep python-2.7` #判断你当前系统上的python 如果是2.7 请单独安装ipython即可
if [ $? -eq 0 ]
then
        echo "你的python版本是2.7及以上，请单独安装iPython Usage：yum install ipython 或者看下面安装ipython的方法即可"
        exit 0
fi
############################################################################################
if [ -d $dir ]
then
        echo "iPython exist"
else
        sudo mkdir iPython
fi
############################################################################################
cd iPython
if [ -f $file ]
then
        echo "$file is exist"
        tar xf Python-2.7.8.tar.xz
        cd Python-2.7.8
        ./configure --prefix=/usr/local/python27
        sudo make && make install
else
        wget https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tar.xz
        tar xf Python-2.7.8.tar.xz
        cd Python-2.7.8
        sudo ./configure --prefix=/usr/local/python27
        sudo make && make install
fi
##############################################################################################
#Python 安装  依赖python2.7
if [ -f $file2 ]
then
        echo "$file1 is exist"
        tar xf ipython-2.3.1.tar.gz
        cd ipython-2.3.1
        sudo /usr/local/python27/bin/python2.7 setup.py build
        sudo /usr/local/python27/bin/python2.7 setup.py install
 
else
        wget https://pypi.python.org/packages/source/i/ipython/ipython-2.3.1.tar.gz#md5=2b7085525dac11190bfb45bb8ec8dcbf
        tar xf ipython-2.3.1.tar.gz
        cd ipython-2.3.1
        sudo /usr/local/python27/bin/python2.7 setup.py build
        sudo /usr/local/python27/bin/python2.7 setup.py install
fi

找出活动ip 
#!/bin/bash
ips="192.168.1."
for i in `seq 1 254`
do
ping -c 2 $ips$i >/dev/null 2>/dev/null
if [ $? == 0 ]
then
    echo "echo $ips$i is online"
else
    echo "echo $ips$i is not online"
fi
done

ips="/root/telnet"
username=``cat telnet_source | awk -F : '{print $1,$2,$3}' | awk  '{print $3}'`
passwd=`cat telnet_source | awk -F : '{print $1,$2,$3}' | awk  '{print $4}'`
for i in $ips
do
telnet $ips  $username 




日志归档 
#!/bin/bash
function e_df()
{
    [ -f $1 ] && rm -f $1
}

for i in `seq 5 -1 2`
do
    i2=$[$i-1]
    e_df /data/1.log.$i
    if [ -f /data/1.log.$i2 ]
    then
        mv /data/1.log.$i2 /data/1.log.$i
    fi
done

e_df /data/1.log.1
mv /data/1.log  /data/1.log.1

检查错误
#!/bin/bash
sh -n $1 2>/tmp/err
if [ $? -eq "0" ]
then
    echo "The script is OK."
else
    cat /tmp/err
    read -p "Please inpupt Q/q to exit, or others to edit it by vim. " n
    if [ -z $n ]
    then
        vim $1
        exit
    fi
    if [ $n == "q" -o $n == "Q" ]
    then
        exit
    else
        vim $1
        exit
    fi
fi

#格式化数字串 
#!/bin/bash
read -p "输入一串数字：" num
v=`echo $num|sed 's/[0-9]//g'`
if [ -n "$v" ]
then
    echo "请输入纯数字."
    exit
fi
length=${#num}
len=0
sum=''
for i in $(seq 1 $length)
do
        len=$[$len+1]
        if [[ $len == 3 ]]
        then
                sum=','${num:$[0-$i]:1}$sum
                len=0
        else
                sum=${num:$[0-$i]:1}$sum
        fi
done
if [[ -n $(echo $sum | grep '^,' ) ]]
then
        echo ${sum:1}
else
        echo $sum
fi



上面这个答案比较复杂，下面再来一个sed的
#!/bin/bash
read -p "输入一串数字：" num
v=`echo $num|sed 's/[0-9]//g'`
if [ -n "$v" ]
then
    echo "请输入纯数字."
    exit
fi
echo $num|sed -r '{:number;s/([0-9]+)([0-9]{3})/\1,\2/;t number}'


#判断用户是否登录
#!/bin/bash
read -p "Please input the username: " user
if who | grep -qw $user
then
    echo $user is online.
else
    echo $user not online.
fi

2. 
#!/bin/bash
function message()
{
    echo "0. w"
    echo "1. ls"
    echo "2.quit"
    read -p "Please input parameter: " Par
}
message
while [ $Par -ne '2' ] ; do
    case $Par in
    0)
        w
        ;;
    1)
        ls
        ;;
    2)
        exit
        ;;
    *)
        echo "Unkown command"
        ;;
  esac
  message
done


#shell脚本批量telnet ip port
PORT=XXXXX
count=0  
for i in $(cat ip_list.dat)  
do 
    ((count++))  
    echo "count=$count" 
    # 关键代码，1s自动结束telnet  
    (sleep 1;) | telnet $i $PORT >> telnet_result.txt  
done 
# 根据结果判断出正常可以ping通的ip  
cat telnet_result.txt | grep -B 1 \] | grep [0-9] | awk '{print $3}' | cut -d '.' -f 1,2,3,4 > telnet_alive.txt   
# 差集，得到ping不同的ip  
cat ip_list.dat telnet_alive.txt | sort | uniq -u > telnet_die.txt






#shell收集ip脚本；从APNIC获取数据
#!/bin/sh
#auto get the IP Table
#get the newest delegated-apnic-latest
rm delegated-apnic-latest
if type wget
then wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
else fetch http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
fi
grep 'apnic|CN|ipv4' delegated-apnic-latest | cut -f 4,5 -d '|' | tr '|' ' ' | while read ip cnt
do
mask=$(bc <<END | tail -1
pow=32;
define log2(x) {
if (x<=1) return (pow);
pow--;
return(log2(x/2));
}
log2($cnt);
END
)
echo $ip/$mask';'>>cnnet
resultext=`whois $ip@whois.apnic.net | grep -e ^netname -e ^descr -e ^role -e ^mnt-by | cut -f 2 -d ':' | sed 's/ *//'`
if echo $resultext | grep -i -e 'railcom' -e 'crtc' -e 'railway'
then echo $ip/$mask';' >> crc
elif echo $resultext | grep -i -e 'cncgroup' -e 'netcom'
then echo $ip/$mask';' >> cnc
elif echo $resultext | grep -i -e 'chinanet' -e 'chinatel'
then echo $ip/$mask';' >> telcom_acl
elif echo $resultext | grep -i -e 'unicom'
then echo $ip/$mask';' >> unicom
elif echo $resultext | grep -i -e 'cmnet'
then echo $ip/$mask';' >> cmnet
else
echo $ip/$mask';' >> other_acl
fi
done

#修改网卡
#!/bin/bash
## 设置IP  2017-08-31
##robert yu
##centos 6和centos 7

#nmcli con show |grep enp0s3 | awk -F '[ ]+' '{print $2}'
#nmcli device show enp0s3
#nmcli device show enp0s3 | awk 'NR==3'
#bash ip.sh enp0s3 10.0.2.18 255.255.255.0 10.0.2.2
#bash ip.sh enp0s8 192.168.56.104 255.255.255.0 192.168.56.1 dg

if [ "$1" == "" ];then
    echo "1 is empty.example:ip.sh eth0 192.168.1.10 255.255.255.0 192.168.1.1"
    exit 1
fi
if [ "$2" == "" ];then
    echo "2 is empty.example:ip.sh eth0 192.168.1.10 255.255.255.0 192.168.1.1"
    exit 1
fi
if [ "$3" == "" ];then
    echo "3 is empty.example:ip.sh eth0 192.168.1.10 255.255.255.0 192.168.1.1"
    exit 1
fi
if [ "$4" == "" ];then
    echo "4 is empty.example:ip.sh eth0 192.168.1.10 255.255.255.0 192.168.1.1"
    exit 1
fi

ID1=$1
ID5=$5
###删除网关或DNS
dg_ddg(){
if [ "$ID5" == "dg" ];then
    sed -i '/GATEWAY=/d' /etc/sysconfig/network-scripts/ifcfg-$ID1
fi
if [ "$ID5" == "ddg" ];then
    sed -i '/GATEWAY=/d' /etc/sysconfig/network-scripts/ifcfg-$ID1
	sed -i '/DNS1=/d' /etc/sysconfig/network-scripts/ifcfg-$ID1
	sed -i '/DNS2=/d' /etc/sysconfig/network-scripts/ifcfg-$ID1
fi
if [ "$ID5" == "dd" ];then
	sed -i '/DNS1=/d' /etc/sysconfig/network-scripts/ifcfg-$ID1
	sed -i '/DNS2=/d' /etc/sysconfig/network-scripts/ifcfg-$ID1
fi
}

###系统判断
if [ -f /etc/redhat-release ];then
        OS=CentOS
check_OS1=`cat /etc/redhat-release | awk -F '[ ]+' '{print $3}' | awk -F '.' '{print $1}'`
check_OS2=`cat /etc/redhat-release | awk -F '[ ]+' '{print $4}' | awk -F '.' '{print $1}'`
if [ "$check_OS1" == "6" ];then
    OS=CentOS6
fi
if [ "$check_OS2" == "7" ];then
    OS=CentOS7
fi
elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
else
        echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
fi

	if [ $OS == 'CentOS6' ];then

###centos6修改
if [ -f "/etc/sysconfig/network-scripts/ifcfg-$1" ]; then

time=`date +%Y-%m-%d_%H_%M_%S`
cp /etc/sysconfig/network-scripts/ifcfg-$1 /tmp/ifcfg-$1.$time


HWADDR=`/sbin/ip a|grep -B1 $1 | awk 'NR==3' |awk -F '[ ]+' '{print $3}'`
sed -i '/BOOTPROTO=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/HWADDR=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/ONBOOT=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/IPADDR=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/NETMASK=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/GATEWAY=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/DNS1=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/DNS2=/d' /etc/sysconfig/network-scripts/ifcfg-$1
echo "BOOTPROTO=static" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "HWADDR=$HWADDR" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "ONBOOT=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "IPADDR=$2" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "NETMASK=$3" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "GATEWAY=$4" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS1=114.114.114.114" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS2=223.5.5.5" >>/etc/sysconfig/network-scripts/ifcfg-$1

dg_ddg

cat /etc/sysconfig/network-scripts/ifcfg-$1
echo "$1 ok"

else

HWADDR=`/sbin/ip a|grep -B1 $1 | awk 'NR==3' |awk -F '[ ]+' '{print $3}'`
echo "TYPE=Ethernet" >/etc/sysconfig/network-scripts/ifcfg-$1
echo "DEVICE=$1" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "NM_CONTROLLED=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1

echo "BOOTPROTO=static" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "HWADDR=$HWADDR" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "ONBOOT=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "IPADDR=$2" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "NETMASK=$3" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "GATEWAY=$4" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS1=114.114.114.114" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS2=223.5.5.5" >>/etc/sysconfig/network-scripts/ifcfg-$1

dg_ddg

cat /etc/sysconfig/network-scripts/ifcfg-$1

fi
		echo CentOS6
	fi
	if [ $OS == 'CentOS7' ];then

###centos7修改
if [ -f "/etc/sysconfig/network-scripts/ifcfg-$1" ]; then

time=`date +%Y-%m-%d_%H_%M_%S`
cp /etc/sysconfig/network-scripts/ifcfg-$1 /tmp/ifcfg-$1.$time


UUID=`nmcli con show |grep $1 | awk -F '[ ]+' '{print $2}'`
sed -i '/BOOTPROTO=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/IPV6INIT=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/ONBOOT=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/UUID=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/IPADDR=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/NETMASK=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/GATEWAY=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/DNS1=/d' /etc/sysconfig/network-scripts/ifcfg-$1
sed -i '/DNS2=/d' /etc/sysconfig/network-scripts/ifcfg-$1
echo "IPV6INIT=no" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "BOOTPROTO=static" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "ONBOOT=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "UUID=$UUID" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "IPADDR=$2" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "NETMASK=$3" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "GATEWAY=$4" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS1=114.114.114.114" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS2=223.5.5.5" >>/etc/sysconfig/network-scripts/ifcfg-$1

dg_ddg

cat /etc/sysconfig/network-scripts/ifcfg-$1
echo "$1 ok"

else

UUID=`nmcli con show |grep $1 | awk -F '[ ]+' '{print $2}'`
echo "TYPE=Ethernet" >/etc/sysconfig/network-scripts/ifcfg-$1
echo "DEFROUTE=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "PEERDNS=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "PEERROUTES=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "IPV4_FAILURE_FATAL=no" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "NAME=$1" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DEVICE=$1" >>/etc/sysconfig/network-scripts/ifcfg-$1

echo "IPV6INIT=no" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "BOOTPROTO=static" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "ONBOOT=yes" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "UUID=$UUID" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "IPADDR=$2" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "NETMASK=$3" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "GATEWAY=$4" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS1=114.114.114.114" >>/etc/sysconfig/network-scripts/ifcfg-$1
echo "DNS2=223.5.5.5" >>/etc/sysconfig/network-scripts/ifcfg-$1

dg_ddg

cat /etc/sysconfig/network-scripts/ifcfg-$1

fi
echo CentOS7
fi




#DNS服务器自动化部署(全自动)
#!/bin/bash

INSTALL(){
yum install -y bind bind-chroot
}

ETC1(){
#sed -i 's/127.0.0.1/any/;s/::1/any/;s/localhost/any/' /etc/named.conf
sed -i 's/{.*; };/{ any; };/' /etc/named.conf
}

checkdomain (){
[[ $1 =~ \. ]] && echo 0 || echo 1;
}

checkip () {
if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
    IP=(${1//\./ })
    [ ${IP[0]} -gt 0 -a ${IP[0]} -lt 255 ] && [ ${IP[1]} -ge 0 -a ${IP[1]} -le 255 ] && [ ${IP[2]} -ge 0 -a ${IP[2]} -le 255 ] && [ ${IP[3]} -gt 0 -a ${IP[3]} -lt 255 ] && echo 0 || echo 1
 
else
        echo 1
fi
}
		
RFC () {
DOM=${domain#*.}
HO=${domain%%.*}
IP=(${ipadd//./ })
RFC="/etc/named.rfc1912.zones"
#RFC=/tmp/named.rfc1912.zones

if grep "$DOM" $RFC &> /dev/null
then
	read
else 
cat >> $RFC << ENDF
zone "$DOM" IN {
        type master;
        file "named.$DOM";
        allow-update { none; };
};
ENDF
fi

if grep "${IP[2]}.${IP[1]}.${IP[0]}" $RFC &> /dev/null
then
	read
else
cat >> $RFC << ENDF
zone "${IP[2]}.${IP[1]}.${IP[0]}.in-addr.arpa" IN {
        type master;
        file "named.arpa.$DOM";
        allow-update { none; };
};
ENDF
fi

ls /var/named/named.$DOM &> /dev/null || (cp -rp /var/named/named.localhost /var/named/named.$DOM && sed -i '9,10d' /var/named/named.$DOM)
grep -v "SOA" /var/named/named.$DOM|grep "A" &> /dev/null || sed -i "\$a\\\tA\t$ipadd" /var/named/named.$DOM
grep "$HO" /var/named/named.$DOM &> /dev/null || sed -i "\$a$HO\tA\t$ipadd" /var/named/named.$DOM


ls /var/named/named.arpa.$DOM &> /dev/null || (cp -rp /var/named/named.loopback /var/named/named.arpa.$DOM && sed -i '8,$d' /var/named/named.arpa.$DOM)
grep NS /var/named/named.arpa.$DOM &> /dev/null || sed -i "\$a\\\tNS\t$DOM." /var/named/named.arpa.$DOM
grep "PTR     $DOM." /var/named/named.arpa.$DOM &> /dev/null || sed -i "\$a${IP[3]}\tPTR\t$DOM." /var/named/named.arpa.$DOM
grep "${IP[3]}       PTR     $domain." /var/named/named.arpa.$DOM  &> /dev/null || sed -i "\$a${IP[3]}\tPTR\t$domain." /var/named/named.arpa.$DOM

}

SERVICE(){
systemctl start named
}

READ () {
read -p "请输入要设置的正向解析域名:" domain
read -p "请输入要设置的正向解析域名所对应的ip地址:" ipadd
}


# 程序正文
#安装软件
echo "1.开始安装DNS相关程序"
read
INSTALL
#配置文件/etc/named.conf
echo "2.配置文件/etc/named.conf"
read
ETC1
#配置正反解析
echo "3.配置正反解析"
read
until [[ `checkdomain $domain` -eq 0 && `checkip $ipadd` -eq 0 ]]
do
	READ

	
	if [[ `checkdomain $domain` -eq 0 && `checkip $ipadd` -eq 0 ]]
	then
		RFC
	elif [[ `checkdomain $domain` -eq 1 && `checkip $ipadd` -eq 0 ]] 
		then 
			echo "域名不正确"
		elif	[[ `checkdomain $domain` -eq 0 && `checkip $ipadd` -eq 1 ]] 
			then 
				echo "ip地址不正确"
			else 
				echo "域名和ip都不正确"
	fi
done

# 配置结束
echo "4.启动服务"
read
SERVICE 

# 查看服务状态
read
systemctl status named









#部署DNS2
#!/bin/bash
INSTALL(){
yum install -y bind bind-chroot
}

ETC1(){
#sed -i 's/127.0.0.1/any/;s/::1/any/;s/localhost/any/' /etc/named.conf
sed -i 's/{.*; };/{ any; };/' /etc/named.conf
}
ETC2(){
cat >> /etc/named.rfc1912.zones << ENDF
zone "uplooking.com" IN {
        type master;
        file "named.uplooking.com";
        allow-update { none; };
};
zone "0.25.172.in-addr.arpa" IN {
        type master;
        file "named.arpa.uplooking.com";
        allow-update { none; };
};
ENDF
}

ZONE(){
cp -rp /var/named/named.localhost /var/named/named.uplooking.com
cat > /var/named/named.uplooking.com <<ENDF
\$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
	A	192.168.10.100
www	A	192.168.10.100
ENDF
cp -rp /var/named/named.loopback /var/named/named.arpa.uplooking.com
cat > /var/named/named.arpa.uplooking.com <<ENDF
\$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      uplooking.com.
        PTR	uplooking.com.
11	PTR	www.uplooking.com.
ENDF

}

SERVICE(){
systemctl start named
}

INSTALL
#ETC1
#ETC2
#ZONE
#SERVICE


#取石子游戏
#!/bin/bash
read -p "游戏开始！请玩家指定石子的个数:" n1
read -p "请玩家指定每次取石子的最多个数:" n2

k=$(($n1%($n2+1)))
j=$(($n1/($n2+1)))


HH () {
for i in `seq 1 $j`
do
	read -p "请玩家取石子:" w
	echo "我取 $((($n2+1)-$w)) 个石子"
	q=$(($q-($n2+1)))
	echo "目前还剩下 $q 个石子"
	[ $q -eq 0 ] && echo "你受到了来自大牙的嘲讽!哈哈哈哈哈哈!"
done
}

if [[ $k -gt 0 ]]
then
	echo "我先取 $k 个石子"	
	q=$(($n1-$k))
	echo "目前还剩下 $q 个石子"
	HH
else
	q=$n1
	HH
fi








































#Congratulations，you have successfully recertified as a CCIE！ periodi recertification
#ensures that the CCIE designation remains a vaild measure of expertise in the networking
#industry
#Your next CCIE  recertification deadline will be August 27 2019. Current recertification policies 
#require you to pass one written expert level exam within the 24 mouths preceding you deadline. 
#However，you may not schedule the same exam you just passwd for at least six mouths. 
#You may take the written exam for a track different from the one you are certified 
#in to meet the recertification requirement. Written exams are schedules through Ciscos authorized testing partner,pearson Vue.




