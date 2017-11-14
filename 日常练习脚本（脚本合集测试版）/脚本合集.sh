#获取ip
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


#列出子目录
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

封禁ip
#!/bin/bash
#echo "*/5 * * * * root /root/block_ssh.sh" >>/etc/crontab
LIMIT=30
LOGFILE="/data/block_ip.log"
TIME=$(date '+%b %e %H')
BLOCK_IP=`perl -lane 'print $F[-4] if /Failed password/' /var/log/secure|sort|uniq -c|perl -lane  'print "$F[0]:$F[1]"  if ($F[0] > "'$LIMIT'")'`
 
for i in $BLOCK_IP
do
 
  echo $i
     IP=`echo $i|perl -F: -lane 'print $F[1]'`
     echo $IP
     iptables-save|grep INPUT|grep DROP|grep $IP>/dev/null     #先判断下是否已经被屏蔽
     if [ $? -gt 0 ];then
          iptables -I INPUT -s $IP -j DROP     #屏蔽ip
          NOW=$(date '+%Y-%m-%d %H:%M')
          echo -e "$NOW : $IP" >>${LOGFILE}
     fi
done



for i in `awk '/Failed/{print $(NF-3)}' /var/log/secure|sort|uniq -c|sort -rn|awk '{if ($1>$num){print $2}}'`   
do           
iptables -I INPUT -p tcp -s $i --dport 22 -j DROP    
 done 



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


python脚本
#!/usr/bin/env python
#-*- coding: UTF-8 -*-
import os,sys
reload(sys)
sys.setdefaultencoding('utf8')
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
提示：
1. 你可以使用ping命令   ping -c10 123.23.11.21
2. 发邮件脚本可以参考 https://coding.net/u/aminglinux/p/aminglinux-book/git/blob/master/D22Z/mail.py
3. 脚本可以搞成死循环，每隔30s检测一次
netstat -ant |grep ':80 ' |grep ESTABLISHED|wc –l   #获取80端口并发连接数

#!/bin/bash

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





#!/bin/bash
#检查是否已经安装DNS
[ -e /etc/named.conf ]
if [ $? -eq 1 ]
then
        echo "没有安装DNS服务，开始问您安装DNS服务"
        cd /media/RHEL_6.4\ x86_64\ Disc\ 1/Packages/
        rpm -ivh bind-9.8.2-0.17.rc1.el6.x86_64.rpm bind-chroot-9.8.2-0.17.rc1.el6.x86_64.rpm >> /dev/null
#定义DNS配置文件
file=/etc/named.conf
#获取ip
ip=$(ifconfig | grep "inet addr" |grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}')
#修改DNS配置文件中监听的ip地址
sed -i "s/127.0.0.1/$ip/" $file
#修改允许使用本DNS服务的网段
sed -i "s/localhost/any/" $file
#添加zone域名
echo -n " 请输入zone域名："
read line
zone01=$line
echo "zone \"$zone01\" IN {
        type master;
        file \"$zone01.zone\";
};" >> /etc/named.conf
#编写区域文件
#定义域前缀
echo "#########################开始配置区域文件################################"
echo -n " 请输入域名前缀："
read line
domain=$line
echo '$TTL 86400' > ar/named/$zone01.zone
cat>>ar/named/$zone01.zone<<EOF 
@  IN SOA  $zone01  root.$zone01. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       IN      NS              ns1.$zone01.
ns1     IN      A               $ip
$domain IN      A               $ip
EOF

#启动DNS
echo "############################启动DNS服务##################################"
service named start
#查看是否启动DNS
echo "########################查看DNS服务的运行状态############################"
service named status | grep named 
#是否需要继续添加主机记录
echo "D N S 服 务 安 装 完 成 "
else
echo "已经安装DNS服务，是否需要添加主机记录？（yes）"





#下面是用来追加主机记录用的，我的要求是：运行这个脚本，首先检查是否安装DNS，否则安装，是则运行追加主机记录的脚本，现在问题是我的计算机已经安装了DNS，需要添加主机记录，但我不管输入yes还no他都自己执行下面的脚本了。望大神改进，谢谢！


#是否需要继续添加主机记录
#echo -n "是否需要继续添加主机记录（yes）"
read line
peizhi=$line
if [ "$peizhi"="yes" ]
then
echo -n "请输入您的区域文件名："
read line
quyuming=$line
echo -n "请输入需要添加主机记录的个数："
read line
geshu=$line
i=1
while (($i<=$geshu))
  do
       echo -n "请输入域名："
       read line
       yuming=$line
       echo -n "请输入主机地址："
       read line
       IP=$line
       echo "$yuming   IN    A   $IP " >>  /var/named/$quyuming
let i++
done
fi
fi




#! /bin/bash
  IP="10.10.10"
  RIP="10.10.10"
  DN="gr.org"
  Name="10.10.10.10"
  
  cat >> /etc/named.conf << +END+
  zone "$DN." IN {
          type master;
         file "gr.org.db";
 };
 zone "$RIP.in-addr.arpa" IN{
         type master;
         file "$IP.db";
 };
 +END+
 cat > /var/named/$DN.db <<+END+
 \$TTL 86400
 @    IN  SOA    ns.$DN.  root.$DN. (
        20150317  6H  30M  1W  15M)
      IN  NS     ns.$DN.
      IN  MX  10   mail.$DN.
 bbs  IN  CNAME  www.$DN.
 ns   IN  A      $IP.10
 www  IN  A      $IP.10
 mail IN  A      $IP.11
 +END+
 cat > /var/named/$IP.db <<+END+
 \$TTL 86400
 @       IN      SOA     ns.$DN.       root.$DN.(
                 20150317  6H  30M  1W  15M)
         IN      NS      ns.$DN.
 10      IN      PTR     ns.$DN.
 10      IN      PTR     www.$DN.
 11      IN      PTR     mail.$DN.
 +END+
 cat > /etc/resolv.conf <<+END+
 nameserver $Name
 +END+
 
 service named start




nginx防止大量ip攻击脚本
#!/bin/sh
########################################
nginx_home="/usr/local/nginx/conf/vhosts"            #你的nginx配置目录
log_path="/usr/local/nginx/logs/access.log"    #你的日志路径
########################################
tail -100 ${log_path} \
|grep -i -v -E "dnspod|google|yahoo|baidu|msnbot|FeedSky|sogo" \
|awk '{print $1}' |sort |uniq -c|sort -nr|head \
|awk '{if($1&gt;80)print "deny "$2";"}' &gt; ${nginx_home}/deny.conf


测试网站正常(监控服务器运行状态)
#!/bin/bash
#
os_check() {
        if [ -e /etc/redhat-release ]; then
                REDHAT=`cat /etc/redhat-release |cut -d' '  -f1`
        else
                DEBIAN=`cat /etc/issue |cut -d' ' -f1`
        fi
        if [ "$REDHAT" == "CentOS" -o "$REDHAT" == "Red" ]; then
                P_M=yum
        elif [ "$DEBIAN" == "Ubuntu" -o "$DEBIAN" == "ubutnu" ]; then
                P_M=apt-get
        else
                Operating system does not support.
                exit 1
        fi
}
if [ $LOGNAME != root ]; then
    echo "Please use the root account operation."
    exit 1
fi
if ! which vmstat &>/dev/null; then
        echo "vmstat command not found, now the install."
        sleep 1
        os_check
        $P_M install procps -y
        echo "-----------------------------------------------------------------------"
fi
if ! which iostat &>/dev/null; then
        echo "iostat command not found, now the install."
        sleep 1
        os_check
        $P_M install sysstat -y
        echo "-----------------------------------------------------------------------"
fi

while true; do
    select input in cpu_load disk_load disk_use disk_inode mem_use tcp_status cpu_top10 mem_top10 traffic quit; do
        case $input in
            cpu_load)
                #CPU利用率与负载
                echo "---------------------------------------"
                i=1
                while [[ $i -le 3 ]]; do
                    echo -e "\033[32m  参考值${i}\033[0m"
                    UTIL=`vmstat |awk '{if(NR==3)print 100-$15"%"}'`
                    USER=`vmstat |awk '{if(NR==3)print $13"%"}'`
                    SYS=`vmstat |awk '{if(NR==3)print $14"%"}'`
                    IOWAIT=`vmstat |awk '{if(NR==3)print $16"%"}'`
                    echo "Util: $UTIL"
                    echo "User use: $USER"
                    echo "System use: $SYS"
                    echo "I/O wait: $IOWAIT"
                    i=$(($i+1))
                    sleep 1
                done
                echo "---------------------------------------"
                break
                ;;
            disk_load)
                #硬盘I/O负载
                echo "---------------------------------------"
                i=1
                while [[ $i -le 3 ]]; do
                    echo -e "\033[32m  参考值${i}\033[0m"
                    UTIL=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$NF"%"}'`
                    READ=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$6"KB"}'`
                    WRITE=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$7"KB"}'`
                    IOWAIT=`vmstat |awk '{if(NR==3)print $16"%"}'`
                    echo -e "Util:"
                    echo -e "${UTIL}"
                    echo -e "I/O Wait: $IOWAIT"
                    echo -e "Read/s:\n$READ"
                    echo -e "Write/s:\n$WRITE"
                    i=$(($i+1))
                    sleep 1
                done
                echo "---------------------------------------"
                break
                ;;
            disk_use)
                #硬盘利用率
                DISK_LOG=/tmp/disk_use.tmp
                DISK_TOTAL=`fdisk -l |awk '/^Disk.*bytes/&&/\/dev/{printf $2" ";printf "%d",$3;print "GB"}'`
                USE_RATE=`df -h |awk '/^\/dev/{print int($5)}'`
                for i in $USE_RATE; do
                    if [ $i -gt 90 ];then
                        PART=`df -h |awk '{if(int($5)=='''$i''') print $6}'`
                        echo "$PART = ${i}%" >> $DISK_LOG
                    fi
                done
                echo "---------------------------------------"
                echo -e "Disk total:\n${DISK_TOTAL}"
                if [ -f $DISK_LOG ]; then
                    echo "---------------------------------------"
                    cat $DISK_LOG
                    echo "---------------------------------------"
                    rm -f $DISK_LOG
                else
                    echo "---------------------------------------"
                    echo "Disk use rate no than 90% of the partition."
                    echo "---------------------------------------"
                fi
                break
                ;;
            disk_inode)
                #硬盘inode利用率
                INODE_LOG=/tmp/inode_use.tmp
                INODE_USE=`df -i |awk '/^\/dev/{print int($5)}'`
                for i in $INODE_USE; do
                    if [ $i -gt 90 ]; then
                        PART=`df -h |awk '{if(int($5)=='''$i''') print $6}'`
                        echo "$PART = ${i}%" >> $INODE_LOG
                    fi
                done
                if [ -f $INODE_LOG ]; then
                    echo "---------------------------------------"
                    rm -f $INODE_LOG
                else
                    echo "---------------------------------------"
                    echo "Inode use rate no than 90% of the partition."
                    echo "---------------------------------------"
                fi
                break
                ;;
            mem_use)
                #内存利用率
                echo "---------------------------------------"
                MEM_TOTAL=`free -m |awk '{if(NR==2)printf "%.1f",$2/1024}END{print "G"}'`
                USE=`free -m |awk '{if(NR==3) printf "%.1f",$3/1024}END{print "G"}'`
                FREE=`free -m |awk '{if(NR==3) printf "%.1f",$4/1024}END{print "G"}'`
                CACHE=`free -m |awk '{if(NR==2) printf "%.1f",($6+$7)/1024}END{print "G"}'`
                echo -e "Total: $MEM_TOTAL"
                echo -e "Use: $USE"
                echo -e "Free: $FREE"
                echo -e "Cache: $CACHE"
                echo "---------------------------------------"
                break
                ;;
            tcp_status)
                #网络连接状态
                echo "---------------------------------------"
                COUNT=`netstat -antp |awk '{status[$6]++}END{for(i in status) print i,status}'`
                echo -e "TCP connection status:\n$COUNT"
                echo "---------------------------------------"
                ;;
            cpu_top10)
                #占用CPU高的前10个进程
                echo "---------------------------------------"
                CPU_LOG=/tmp/cpu_top.tmp
                i=1
                while [[ $i -le 3 ]]; do
                    #ps aux |awk '{if($3>0.1)print "CPU: "$3"% -->",$11,$12,$13,$14,$15,$16,"(PID:"$2")" |"sort -k2 -nr |head -n 10"}' > $CPU_LOG
                    ps aux |awk '{if($3>0.1){{printf "PID: "$2" CPU: "$3"% --> "}for(i=11;i<=NF;i++)if(i==NF)printf $i"\n";else printf $i}}' |sort -k4 -nr |head -10 > $CPU_LOG
                    #循环从11列（进程名）开始打印，如果i等于最后一行，就打印i的列并换行，否则就打印i的列
                    if [[ -n `cat $CPU_LOG` ]]; then
                       echo -e "\033[32m  参考值${i}\033[0m"
                       cat $CPU_LOG
                       > $CPU_LOG
                    else
                        echo "No process using the CPU." 
                        break
                    fi
                    i=$(($i+1))
                    sleep 1
                done
                echo "---------------------------------------"
                break
                ;;
            mem_top10)
                #占用内存高的前10个进程
                echo "---------------------------------------"
                MEM_LOG=/tmp/mem_top.tmp
                i=1
                while [[ $i -le 3 ]]; do
                    #ps aux |awk '{if($4>0.1)print "Memory: "$4"% -->",$11,$12,$13,$14,$15,$16,"(PID:"$2")" |"sort -k2 -nr |head -n 10"}' > $MEM_LOG
                    ps aux |awk '{if($4>0.1){{printf "PID: "$2" Memory: "$3"% --> "}for(i=11;i<=NF;i++)if(i==NF)printf $i"\n";else printf $i}}' |sort -k4 -nr |head -10 > $MEM_LOG
                    if [[ -n `cat $MEM_LOG` ]]; then
                        echo -e "\033[32m  参考值${i}\033[0m"
                        cat $MEM_LOG
                        > $MEM_LOG
                    else
                        echo "No process using the Memory."
                        break
                    fi
                    i=$(($i+1))
                    sleep 1
                done
                echo "---------------------------------------"
                break
                ;;
            traffic)
                #查看网络流量
                while true; do
                    read -p "Please enter the network card name(eth[0-9] or em[0-9]): " eth
                    #if [[ $eth =~ ^eth[0-9]$ ]] || [[ $eth =~ ^em[0-9]$ ]] && [[ `ifconfig |grep -c "\<$eth\>"` -eq 1 ]]; then
                    if [ `ifconfig |grep -c "\<$eth\>"` -eq 1 ]; then
                            break
                    else
                        echo "Input format error or Don't have the card name, please input again."
                    fi
                done
                echo "---------------------------------------"
                echo -e " In ------ Out"
                i=1
                while [[ $i -le 3 ]]; do
                    #OLD_IN=`ifconfig $eth |awk '/RX bytes/{print $2}' |cut -d: -f2`
                    #OLD_OUT=`ifconfig $eth |awk '/RX bytes/{print $6}' |cut -d: -f2`
                    OLD_IN=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==5)print $6}'`
                    #CentOS6和CentOS7 ifconfig输出进出流量信息位置不同，CentOS6中RX与TX行号等于8，CentOS7中RX行号是5，TX行号是5，所以就做了个判断.       
                    OLD_OUT=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==7)print $6}'`
                    sleep 1
                    NEW_IN=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==5)print $6}'`
                    NEW_OUT=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==7)print $6}'`
                    IN=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_IN}-${OLD_IN}))'/1024/128}'`
                    OUT=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_OUT}-${OLD_OUT}))'/1024/128}'`
                    echo "${IN}MB/s ${OUT}MB/s"
                    i=$(($i+1))
                    sleep 1
                done
                echo "---------------------------------------"
                break
                ;;
                        quit)
                                exit 0
                                ;;
               *)
                    echo "---------------------------------------"
                    echo "Please enter the number." 
                    echo "---------------------------------------"
                    break
                    ;;
        esac
    done
done



检查负载均衡
#!/bin/bash  
#使用uptime命令监控linux系统负载变化  
#提取本服务器的IP地址信息  
IP=`ifconfig eth0 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`  
#抓取cpu的总核数  
cpu_num=`grep -c 'model name' /proc/cpuinfo`  
#抓取当前系统15分钟的平均负载值  
load_15=`uptime | awk '{print $NF}'`  
#计算当前系统单个核心15分钟的平均负载值，结果小于1.0时前面个位数补0。  
average_load=`echo "scale=2;a=$load_15/$cpu_num;if(length(a)==scale(a)) print 0;print a" | bc`  
#取上面平均负载值的个位整数  
average_int=`echo $average_load | cut -f 1 -d "."`  
#设置系统单个核心15分钟的平均负载的告警值为0.70(即使用超过70%的时候告警)。  
load_warn=0.70  
#当单个核心15分钟的平均负载值大于等于1.0（即个位整数大于0） ，直接发邮件告警；如果小于1.0则进行二次比较  
if (($average_int > 0)); then  
      echo "$IP服务器15分钟的系统平均负载为$average_load，超过警戒值1.0，请立即处理！！！" | mutt -s "$IP 服务器系统负载严重告警！！！"  test@126.com  
else  
#当前系统15分钟平均负载值与告警值进行比较（当大于告警值0.70时会返回1，小于时会返回0 ）  
load_now=`expr $average_load \> $load_warn`  
#如果系统单个核心15分钟的平均负载值大于告警值0.70（返回值为1），则发邮件给管理员  
if (($load_now == 1)); then  
    echo "$IP服务器15分钟的系统平均负载达到 $average_load，超过警戒值0.70，请及时处理。" | mutt -s "$IP 服务器系统负载告警"  test@126.com  
fi  
fi

监控网卡
#!/bin/bash
LANG=en
n1=`sar -n DEV 1 60 |grep eth0 |grep -i average|awk '{print $5}'|sed 's/\.//g'`
n2=`sar -n DEV 1 60 |grep eth0 |grep -i average|awk '{print $6}'|sed 's/\.//g'`
if [ $n1 == "000" ] && [ $n2 == "000" ]
then
    ifdown eth0
    ifup eth0
fi
然后写个cron，10分钟执行一次


监控web可用性
#/bin/bash
url="www.baidu.com"
sta=`curl -I $url 2>/dev/null |head -1 |awk '{print $2}'`
if [ $sta != "200" ]
then
    python /usr/local/sbin/mail.py xxx@qq.com "$url down." "$url down"
fi

文件打包
#!/bin/bash
t=`date +%F`
cd $HOME
tar czf $t.tar.gz `find . -type f -size -5k`


判断日期合法
#!/bin/bash
#check date
if [ $# -ne 1 ] || [ ${#1} -ne 8 ]
then
    echo "Usage: bash $0 yyyymmdd"
    exit 1
fi
datem=$1
year=${datem:0:4}
month=${datem:4:2}
day=${datem:6:2}
if echo $day|grep -q '^0'
then
    day=`echo $day |sed 's/^0//'`
fi
if cal $month $year >/dev/null 2>/dev/null
then
    daym=`cal $month $year|egrep -v "$year|Su"|grep -w "$day"`
    if [ "$daym" != "" ]
    then
        echo ok
    else
        echo "Error: Please input a wright date."
    exit 1
    fi
else
    echo "Error: Please input a wright date."
    exit 1
fi

检查服务
#!/bin/bash
if_install()
{
    n=`rpm -qa|grep -cw "$1"`
    if [ $n -eq 0 ]
    then
    echo "$1 not install."
    yum install -y $1
    else
    echo "$1 installed."
    fi
}
if_install httpd
if_install mysql-server
chk_ser()
{
    p_n=`ps -C "$1" --no-heading |wc -l`
    if [ $p_n -eq 0 ]
    then
    echo "$1 not start."
    /etc/init.d/$1 start
    else
    echo "$1 started."
    fi
}
chk_httpd
chk_mysqld



随机3位数
#!/bin/bash
get_a_num() {
    n=$[$RANDOM%10]
    echo $n
}

get_numbers() {
    for i in 1 2 3; do
        a[$i]=`get_a_num`
    done
    echo ${a[@]}
}

if [ -n "$1" ]; then
    m=`echo $1|sed 's/[0-9]//g'`
    if [ -n "$m" ]; then
        echo "Useage bash $0 n, n is a number, example: bash $0 5"
        exit
    else
        for i in `seq 1 $1`
        do
            get_numbers
        done
    fi
else
    get_numbers
fi

批量修改文件日期
#!/bin/bash
echo -e "Please specify \033[31m Year(with Format:YY):\033[0m"
read YY 
echo -e "Please specify \033[31m Start Month:\033[0m"
read SMM
echo -e "Please specify \033[31m End Month:\033[0m"
read EMM
echo -e "Please specify \033[31m Start Day:\033[0m"
read SDD
echo -e "Please specify \033[31m End Day:\033[0m"
read EDD
echo -e "Please specify \033[31m Start Hour:\033[0m"
read SHH
echo -e "Please specify \033[31m End Hour:\033[0m"
read EHH

for i in `ls -1 ./file`;do
	function NUM() {
		min=$1
		max=$(($2-$min+1))
		num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
		echo $(($num%$max+$min))
		}
	RM=$(NUM $SMM $EMM)
	RnM=`echo $RM | awk '{printf("%02d\n",$0)}'`
	RD=$(NUM $SDD $EDD)
	RnD=`echo $RD | awk '{printf("%02d\n",$0)}'`
	RH=$(NUM $SHH $EHH)
	RnH=`echo $RH | awk '{printf("%02d\n",$0)}'`
	Rm=$(NUM 1 59)
	Rnm=`echo $Rm | awk '{printf("%02d\n",$0)}'`
	Rs=$(NUM 1 59)
	Rns=`echo $Rs | awk '{printf("%02d\n",$0)}'`

	touch -t $YY$RnM$RnD$RnH$Rnm.$Rns ./file/$i
done












shell的getops
#!/bin/bash
ip add |awk -F ":" '$1 ~ /^[1-9]/ {print $2}'|sed 's/ //g' > /tmp/eths.txt
[ -f /tmp/eth_ip.log ] && rm -f /tmp/eth_ip.log
for eth in `cat /tmp/eths.txt`
do
    ip=`ip add |grep -A2 ": $eth" |grep inet |awk '{print $2}' |cut -d '/' -f 1`
    echo "$eth:$ip" >> /tmp/eth_ip.log
done

useage()
{
    echo "Please useage: $0 -i 网卡名字 or $0 -I ip地址"
}

wrong_eth()
{
    if ! grep -q "$1" /tmp/eth_ip.log
    then
        echo "请指定正确的网卡名字"
    exit
    fi
}

wrong_ip()
{
    if ! grep -qw "$1" /tmp/eth_ip.log
    then
        echo "请指定正确的ip地址"
    exit
    fi
}

if [ $# -ne 2 ]
then
    useage
    exit
fi

case $1 in
    -i)
    wrong_eth $2 
    grep $2 /tmp/eth_ip.log |awk -F ':' '{print $2}'
    ;;

    -I)
    wrong_ip $2
    grep $2 /tmp/eth_ip.log |awk -F ':' '{print $1}'
    ;;

    *)
    useage
    exit
esac

三行变一行
sed 'N;N;s/\n/ /g' 1.txt

判断PID是否一致
#!/bin/bash
ps aux|awk '/[0-9]/ {print $2}'|while read pid
do
    result=`find /proc/ -maxdepth 1 -type d -name "$pid"`
    if [ -z $result ]; then
        echo "$pid abnormal!"
    fi
done

更改后缀名
1
#!/bin/bash
find . -type f -name "*.txt" > /tmp/txt.list
for f in `cat /tmp/txt.list`
do
    n=`echo $f|sed -r 's/(.*)\.txt/\1/'`
    echo "mv $f $n.doc"
done

2 
#!/bin/bash
read -p "Please input the username: " user
while :
do
    if who | grep -qw $user
    then
        echo $user login.
    else
        echo $user not login.
    fi
    sleep 300
done

自动重启网卡
#!/bin/bash
export PAHT=$PATH
set -x
test=`ping -c 5 192.168.8.254 | grep "100% packet loss" | wc -l`
test
echo $test
if [ $test = 0 ];
then
        echo `date` >> logs
        echo "The network is working" >> logs
else
        /usr/sbin/ifconfig em1 up
fi


随机生成两位数，01 02 一直到10 需要指定  批量修改文件名



杀死进程 
#!/bin/bash
ps -u $USER |awk '$NF ~ /daya/ {print $1}'|xargs kill 


判断有无关系（a.txt有b.txt没有）
#!/bin/bash
n=`wc -l a.txt|awk '{print $1}'`
[ -f c.txt ] && rm -f c.txt
for i in `seq 1 $n`
do
    l=`sed -n "$i"p a.txt`
    if ! grep -q "^$l$" b.txt
    then
    echo $l >>c.txt
    fi
done
wc -l c.txt
或者用grep实现
grep -vwf b.txt a.txt > c.txt； wc -l c.txt

shell中的小数
#!/bin/bash
a=0.5
b=3
c=`echo "scale=1;$a*$b"|bc`
echo $c


成员分组
假设成员列表文件为members.txt
#!/bin/bash
f=members.txt
n=`wc -l $f|awk '{print $1}'`

get_n()
{
    l=`echo $1|wc -c`
    n1=$RANDOM
    n2=$[$n1+$l]
    g_id=$[$n1%7]
    if [ $g_id -eq 0 ]
    then
	g_id=7
    fi
    echo $g_id
}

for i in `seq 1 7`
do
    [ -f n_$i.txt ] && rm -f n_$i.txt
done

for i in `seq 1 $n`
do
    name=`sed -n "$i"p $f`
    g=`get_n $name`
    echo $name >> n_$g.txt
done

nu(){
    wc -l $1|awk '{print $1}'
}

max(){
    ma=0
    for i in `seq 1 7`
    do
	n=`nu n_$i.txt`
	if [ $n -gt $ma ]
	then
	    ma=$n
	fi
    done
    echo $ma
}

min(){
    mi=50
    for i in `seq 1 7`
    do
	n=`nu n_$i.txt`
	if [ $n -lt $mi ]
	then
	    mi=$n
	fi
    done
    echo $mi
}

ini_min=1

while [ $ini_min -le 7 ]
do
    m1=`max`
    m2=`min`
    ini_min=m2
    for i in `seq 1 7`
    do
	n=`nu n_$i.txt`
	if [ $n -eq $m1 ]
	then
	    f1=n_$i.txt
	elif [ $n -eq $m2 ]
	then
	    f2=n_$i.txt
	fi
    done
    name=`tail -n1 $f1`
    echo $name >> $f2
    sed -i "/$name/d" $f1
    ini_min=$[$ini_min+1]
done

for i in `seq 1 7`
do
    echo "$i 组成员有："
    cat n_$i.txt
    echo
done

计算重复单词个数
假设文档名字叫做a.txt
sed 's/[^a-zA-Z]/ /g' a.txt|xargs -n1 |sort |uniq -c |sort -nr |head

备份etc
#!/bin/sh 
if [ -d /root/bak ]
then
    mkdir /root/bak
fi
prefix=`date +%y%m%d`
d=`date +%m`
if [ $d == "01" ]
then
    cd /etc/
    tar czf  /root/bak/$prefix_etc.tar.gz ./
fi


给文档增加内容
sed -i "5a # This is a test file.\n# Test insert line into this file." 1.txt

打印数字
#!/bin/bash
read -p "请输入您想要暂停的数字：" number_1
for i in `seq 1 $number_1`;
do
        echo $i
done
read -p "是否继续输入数字？" a
if [ $a == "yes" ];then
        read -p "请继续输入您想要暂停的数字：" number_2
        number_3=$[$number_1+1]
        if [ $number_2 -gt $number_1 ];then
                for h in `seq $number_3 $number_2`;
                do
                        echo $h
                done
        else
                echo "输入数字错误，请输入大于的数字!"
        fi
else
        exit
fi

已知nginx访问的日志文件在/usr/local/nginx/logs/access.log内
请统计下早上10点到12点 来访ip最多的是哪个?
日志样例：
111.199.186.68 - [15/Sep/2017:09:58:37 +0800]  "//plugin.php?id=security:job" 200 "POST //plugin.php?id=security:job HTTP/1.1""http://a.lishiming.net/forum.php?mod=viewthread&tid=11338&extra=page%3D1%26filter%3Dauthor%26orderby%3Ddateline" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3141.7 Safari/537.36" "0.516"
203.208.60.208 - [15/Sep/2017:09:58:46 +0800] "/misc.php?mod=patch&action=ipnotice&_r=0.05560809863330207&inajax=1&ajaxtarget=ip_notice" 200 "GET /misc.php?mod=patch&action=ipnotice&_r=0.05560809863330207&inajax=1&ajaxtarget=ip_notice HTTP/1.1""http://a.lishiming.net/forum.php?mod=forumdisplay&fid=65&filter=author&orderby=dateline" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3141.7 Safari/537.36" "0.065"
统计分析日志
grep '15/Sep/2017:1[0-2]:[0-5][0-9]:' /usr/local/nginx/logs/access.log|awk '{print $1}'|sort -n|uniq -c |tail -n1

22端口解封
#!/bin/bashfi

已知nginx访问的日志文件在/usr/local/nginx/logs/access.log内
请统计下早上10点到12点 来访ip最多的是哪个?
日志样例：
111.199.186.68 - [15/Sep/2017:09:58:37 +0800]  "//plugin.php?id=security:job" 200 "POST //plugin.php?id=security:job HTTP/1.1""http://a.lishiming.net/forum.php?mod=viewthread&tid=11338&extra=page%3D1%26filter%3Dauthor%26orderby%3Ddateline" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3141.7 Safari/537.36" "0.516"
203.208.60.208 - [15/Sep/2017:09:58:46 +0800] "/misc.php?mod=patch&action=ipnotice&_r=0.05560809863330207&inajax=1&ajaxtarget=ip_notice" 200 "GET /misc.php?mod=patch&action=ipnotice&_r=0.05560809863330207&inajax=1&ajaxtarget=ip_notice HTTP/1.1""http://a.lishiming.net/forum.php?mod=forumdisplay&fid=65&filter=author&orderby=dateline" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3141.7 Safari/537.36" "0.065"
统计分析日志
grep '15/Sep/2017:1[0-2]:[0-5][0-9]:' /usr/local/nginx/logs/access.log|awk '{print $1}'|sort -n|uniq -c |tail -n1

22端口解封
#!/bin/bash
# check sshd port drop
/sbin/iptables -nvL --line-number|grep "dpt:22"|awk -F ' ' '{print $4}' > /tmp/drop.txt
i=`cat /tmp/drop.txt|head -n 1|egrep -iE "DROP|REJECT"|wc -l`
if [ $i -gt 0 ]
then
    /sbin/iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
fi

统计ip出现次数
awk '{print $1}' ip.txt|sort|uniq -c|awk '{print $2" "$1}'|sort -k2 -r
sort ip.txt|awk '{a[$1]++}END{for(i in a)print i,a[i]}'|sort -k2 -r


#!/bin/bash  
# by liuhx 2013-Nov-04.  
# 设置ftp环境的脚本。ftp的根目录为只读，其下的writable目录为可写  
  
# 可自定义以下四项  
# ftp用户名  
userName="test"  
# ftp密码  
password="test"  
# ftp根目录，末尾不要加/  
ftp_dir="$HOME/ftp"  
# 可写目录的目录名  
writable="writable"  
  
  
# 如果没有加sudo，提示错误并退出  
if [ "x$(id -u)" != x0 ]; then    
  echo "Error: please run this script with 'sudo'."    
  exit 1  
fi  
  
# 核心工具，vsftpd。 -y是对所有提示都回答yes  
sudo apt-get -y install vsftpd  
# db-util是用来生成用户列表数据库的工具  
sudo apt-get -y install db-util  
  
# 以下步骤参考https://help.ubuntu.com/community/vsftpd#The_workshop  
# 创建用户名和密码的数据库，以单数行为用户名，双数行为密码记录  
cd /tmp  
printf "$userName\n$password\n" > vusers.txt  
db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db  
sudo cp -f vsftpd-virtual-user.db /etc/  
cd /etc  
chmod 600 vsftpd-virtual-user.db  
if [ ! -e vsftpd.conf.old ]; then  
    sudo cp -f vsftpd.conf vsftpd.conf.old  
fi  
  
# 创建PAM file。bash的here-document，直接输出这些内容覆盖原文件  
(sudo cat <<EOF  
auth       required     pam_userdb.so db=/etc/vsftpd-virtual-user  
account    required     pam_userdb.so db=/etc/vsftpd-virtual-user  
session    required     pam_loginuid.so  
EOF  
) > pam.d/vsftpd.virtual  
  
# 获取当前的用户名，不能用whoami或$LOGNAME，否则得到的是root  
owner=`who am i| awk '{print $1}'`  
  
# 创建vsftpd的配置文件。转载请注明出处：http://blog.csdn.net/hursing  
(sudo cat <<EOF  
listen=YES  
anonymous_enable=NO  
local_enable=YES  
virtual_use_local_privs=YES  
write_enable=YES  
local_umask=000  
dirmessage_enable=YES  
use_localtime=YES  
xferlog_enable=YES  
connect_from_port_20=YES  
chroot_local_user=YES  
hide_ids=YES  
secure_chroot_dir=/var/run/vsftpd/empty  
pam_service_name=vsftpd.virtual  
guest_enable=YES  
user_sub_token=$USER  
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem  
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key  
EOF  
) > vsftpd.conf  
sudo echo "local_root=$ftp_dir" >> vsftpd.conf  
# 虚拟用户需要映射为本地用户，设为自己，避免权限问题，但同时也令自己对ftp根目录不可写  
sudo echo "guest_username=$owner" >> vsftpd.conf  
  
  
# 设置了每个虚拟用户只可以浏览其根及子目录（否则可访问磁盘根目录），  
# 这样会被要求根目录不可写，所以创建一个writable的子目录  
mkdir "$ftp_dir"  
mkdir "$ftp_dir/$writable"  
sudo chmod a-w "$ftp_dir"  
sudo chown -R $owner:$owner $ftp_dir  
  
sudo /etc/init.d/vsftpd restart  

#!/bin/bash
# by liuhx 2013-Nov-04.
# 设置ftp环境的脚本。ftp的根目录为只读，其下的writable目录为可写

# 可自定义以下四项
# ftp用户名
userName="test"
# ftp密码
password="test"
# ftp根目录，末尾不要加/
ftp_dir="$HOME/ftp"
# 可写目录的目录名
writable="writable"


# 如果没有加sudo，提示错误并退出
if [ "x$(id -u)" != x0 ]; then  
  echo "Error: please run this script with 'sudo'."  
  exit 1
fi

# 核心工具，vsftpd。 -y是对所有提示都回答yes
yum install -y install vsftpd
# db-util是用来生成用户列表数据库的工具
yum install -y install db-util

# 以下步骤参考https://help.ubuntu.com/community/vsftpd #The_workshop
# 创建用户名和密码的数据库，以单数行为用户名，双数行为密码记录
cd /tmp
printf "$userName\n$password\n" > vusers.txt
db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db
 cp -f vsftpd-virtual-user.db /etc/
cd /etc
chmod 600 vsftpd-virtual-user.db
if [ ! -e vsftpd.conf.old ]; then
	cp -f vsftpd.conf vsftpd.conf.old
fi

# 创建PAM file。bash的here-document，直接输出这些内容覆盖原文件
( cat <<EOF
auth       required     pam_userdb.so db=/etc/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd-virtual-user
session    required     pam_loginuid.so
EOF
) > pam.d/vsftpd.virtual

# 获取当前的用户名，不能用whoami或$LOGNAME，否则得到的是root
owner=`who am i| awk '{print $1}'`

# 创建vsftpd的配置文件。
(cat <<EOF
listen=YES
anonymous_enable=NO
local_enable=YES
virtual_use_local_privs=YES
write_enable=YES
local_umask=000
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
hide_ids=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd.virtual
guest_enable=YES
user_sub_token=$USER
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
EOF
) > vsftpd.conf
 echo "local_root=$ftp_dir" >> vsftpd.conf
# 虚拟用户需要映射为本地用户，设为自己，避免权限问题，但同时也令自己对ftp根目录不可写
 echo "guest_username=$owner" >> vsftpd.conf


# 设置了每个虚拟用户只可以浏览其根及子目录（否则可访问磁盘根目录），
# 这样会被要求根目录不可写，所以创建一个writable的子目录
mkdir "$ftp_dir"
mkdir "$ftp_dir/$writable"
chmod a-w "$ftp_dir"
chown -R $owner:$owner $ftp_dir




搭建ftp服务器正式版本
#!/bin/bash
Stack=$1
if [ "${Stack}" = "" ]; then
 Stack="install"
else
 Stack=$1
fi
install_vsftp()
{
 echo "#######################"
 echo -e "\033[33mUsage: $0 {install|add|uninstall}\033[0m"
 echo -e "\033[33msh $0 (default:install)\033[0m"
 echo -e "\033[33msh $0 add (Add FTP user)\033[0m"
 echo -e "\033[33msh $0 uninstall (Uninstall FTP)\033[0m"
 echo "#######################"
 A=`head -c 500 /dev/urandom | tr -dc a-zA-Z | tr [a-z] [A-Z]|head -c 1`
 B=`head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 6`
 C=`echo $RANDOM|cut -c 2`
 rpm -q vsftpd
 if [ "$?" -eq "0" ]; then
 echo "You have to install VSFTPD!"
 else
 netstat -ntulp |grep -w 21
 if [ "$?" -eq "0" ]; then
 echo "Other FTP is already installed"
 else
 read -p "The FTP access directory(default:/home): " directory
 if [ "${directory}" != "" ]; then
 directorys="${directory}"
 else
 directorys="/home"
 fi
 read -p "Please enter the FTP user: " ftp_user
 read -p "Enter the FTP password(default:$A$B$C): " ftp_pass
 if [ "${ftp_pass}" != "" ]; then
 ftp_passa="${ftp_pass}"
 else
 ftp_passa="$A$B$C"
 fi
 yum -y install vsftpd
 if [ "$?" -eq "0" ]; then
 if [ -d ${directorys} ]; then
 chmod -R 777 ${directorys}
 fi
 useradd -d ${directorys} -g ftp -s /sbin/nologin ${ftp_user}
 echo "${ftp_passa}" | passwd --stdin ${ftp_user} > /dev/null
 sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/g' /etc/vsftpd/vsftpd.conf
 sed -i 's/^#chroot_local_user=YES/chroot_local_user=YES/g' /etc/vsftpd/vsftpd.conf
 sed -i 's/^#chroot_list_enable=YES/chroot_list_enable=YES/g' /etc/vsftpd/vsftpd.conf
 echo "userdel ${ftp_user}" >> /etc/vsftpd/user_list.sh
 echo "" > /etc/vsftpd/chroot_list
 chkconfig vsftpd on
 service vsftpd restart
 echo "###################################"
 echo "FTP user:${ftp_user}"
 echo "Ftp password:${ftp_passa}"
 echo "The FTP directory:${directorys}"
 echo "-----------------------------------"
 else
 echo "VSFTPD installation failed!"
 fi
 fi
 fi
}
add_ftp()
{
 A=`head -c 500 /dev/urandom | tr -dc a-zA-Z | tr [a-z] [A-Z]|head -c 1`
 B=`head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 6`
 C=`echo $RANDOM|cut -c 2`
 read -p "The FTP access directory(Such as:/home): " directory
 if [ "${directory}" != "" ]; then
 directorys="${directory}"
 else
 directorys="/home"
 fi
 read -p "Please enter the FTP user: " ftp_user
 read -p "Enter the FTP password(default:$A$B$C): " ftp_pass
 if [ -d ${directorys} ]; then
 chmod -R 777 ${directorys}
 fi
 useradd -d ${directorys} -g ftp -s /sbin/nologin ${ftp_user}
 if [ "${ftp_pass}" != "" ]; then
 ftp_passa="${ftp_pass}"
 else
 ftp_passa="$A$B$C"
 fi
 echo "${ftp_passa}" | passwd --stdin ${ftp_user} > /dev/null
 echo "userdel ${ftp_user}" >> /etc/vsftpd/user_list.sh
 if [ -d ${directorys} ]; then
 chmod -R 777 ${directorys}
 fi
 echo "###################################"
 echo "FTP user:${ftp_user}"
 echo "Ftp password:${ftp_passa}"
 echo "The FTP directory:${directorys}"
 echo "-----------------------------------"

}


uninstall_ftp()
{
yum -y remove vsftpd*
sh /etc/vsftpd/user_list.sh
echo "" > /etc/vsftpd/user_list.sh
}
case "${Stack}" in
 install)
 install_vsftp
 ;;
 add)
 add_ftp
 ;;
 uninstall)
 uninstall_ftp
 ;;
 *)
 echo "Usage: $0 {install|add|uninstall}"
 ;;
esac



#计算器
#!/bin/bash
if [ $# -ne 3 ] 
then
    echo "参数个数不为3"
    echo "当使用乘法时，需要加上脱义符号，例如 $0 1 \* 2"
    exit 1;
fi
num1=`echo $1|sed 's/[0-9.]//g'` ;
if [ -n "$num1" ] 
then
    echo "$1 不是数字" ;
    exit 1
fi

num3=`echo $3|sed 's/[0-9.]//g'` ;
if [ -n "$num3" ]
then
    echo "$3 不是数字" ;
    exit 1
fi

case $2 in
  +)
    echo "scale=2;$1+$3" | bc
    ;;

  -)
    echo "scale=2;$1-$3" | bc 
    ;;
  
  \*)
    echo "scale=2;$1*$3" | bc 
    ;;
  
  /)
    echo "scale=2;$1/$3" | bc 
    ;;
  
  *)
   echo  "$2 不是运算符"
   ;;
esac



#一个简单的审计工具
创建记录日志的目录
# mkdir -p /usr/local/records/

给它任何用户都能读写的权限
# chmod 777 /usr/local/records/

并且要加上防删除权限，谁的目录只能谁删除，其他用户不能删除
# chmod +t /usr/local/domob/records/

# vi /etc/profile  //编辑/etc/profile，加入如下内容
if [ ! -d  /usr/local/records/${LOGNAME} ]
then
    mkdir -p /usr/local/records/${LOGNAME}
    chmod 300 /usr/local/records/${LOGNAME}
fi
export HISTORY_FILE="/usr/local/records/${LOGNAME}/bash_history"
export PROMPT_COMMAND='{ date "+%Y-%m-%d %T ##### $(who am i |awk "{print \$1\" \"\$2\" \"\$5}") #### $(history 1 | { read x cmd; echo "$cmd"; })"; } >>$HISTORY_FILE'


#示例： 如果用户输入数字为5，则最终显示的效果为
■ ■ ■ ■ ■
■ ■ ■ ■ ■
■ ■ ■ ■ ■
■ ■ ■ ■ ■
■ ■ ■ ■ ■

#!/bin/bash
read -p "please input a number:" sum
a=`echo $sum |sed 's/[0-9]//g'`
if [ -n "$a" ]
then
    echo "请输入一个纯数字。"
    exit 1
fi
for n in `seq $sum`
do
    for m in `seq $sum`
    do
        if [ $m -lt $sum ]
        then
            echo -n "■ "
        else
            echo "■"
        fi
    done
done




#iptables脚本
for i in `awk '/Failed/{print $(NF-3)}' /var/log/secure|sort|uniq -c|sort -rn|awk '{if ($1>$num){print $2}}'`   
do           
iptables -I INPUT -p tcp -s $i --dport 22 -j DROP    
 done 
#只要有一次登陆失败就拒绝访问



#检测80端口是否被占用
check_port() {
        echo "Checking instance port ..."
        netstat -tlpn | grep "\b$1\b"
}
if check_port 8080 
then 
        echo "port exists"
    exit 1 
fi


#centos6一键安装lnmp+zabbix服务端(ok)
#!/bin/bash
# install Nginx 1.8.x + mysql5.5.x + PHP-FPM 5.4.x + Zabbix 2.4.7 automatically.
# Tested on CentOS 6.5
##############################################
# 变量
##############################################
err_echo(){
    echo -e "\e[91m[Error]: $1 33[0m"
    exit 1
}
  
info_echo(){
    echo -e "\e[92m[Info]: $1 33[0m"
}
  
warn_echo(){
    echo -e "\e[93m[Warning]: $1 33[0m"
}
  
check_exit(){
    if [ $? -ne 0 ]; then
        err_echo "$1"
        exit1
    fi
}
   
##############################################
# check
##############################################
if [ $EUID -ne 0 ]; then
    err_echo "please run this script as root user."
    exit 1
fi
 
if [ "$(awk '{if ( $3 >= 6.0 ) print "CentOS 6.x"}' /etc/redhat-release 2>/dev/null)" != "CentOS 6.x" ];then
    err_echo "This script is used for RHEL/CentOS 6.x only."
fi
##############################################
# Useradd deploy nginx程序运行账号
##############################################
info_echo "Useradd deploy"
useradd deploy
 
##############################################
# yum repo
##############################################
info_echo "配置yum源......"
if [ ! -f LNMP+zabbix.repo ]; then
cat> /etc/yum.repos.d/LNMP+zabbix.repo <<'EOF'
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/6/$basearch/
gpgcheck=0
enabled=1
  
[webtatic]
name=Webtatic Repository EL6 - $basearch
#baseurl=http://repo.webtatic.com/yum/el6/$basearch/
mirrorlist=http://mirror.webtatic.com/yum/el6/$basearch/mirrorlist
failovermethod=priority
enabled=0
gpgcheck=0
 
[epel] 
name=Extra Packages for Enterprise Linux 6 - $basearch 
baseurl=http://mirrors.aliyun.com/epel/6/$basearch 
http://mirrors.aliyuncs.com/epel/6/$basearch 
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch 
failovermethod=priority 
enabled=1 
gpgcheck=0
 
[remi]
name=Les RPM de remi pour Enterprise Linux 6 - $basearch
#baseurl=http://rpms.famillecollet.com/enterprise/6/remi/$basearch/
mirrorlist=http://rpms.famillecollet.com/enterprise/6/remi/mirror
enabled=1
gpgcheck=0
 
[zabbix]
name=Zabbix Official Repository-$basearch
baseurl=http://repo.zabbix.com/zabbix/2.4/rhel/6/$basearch/
enabled=1
gpgcheck=0
  
[zabbix-non-supported]
name=Zabbix Official Repository non-supported-$basearch
baseurl=http://repo.zabbix.com/non-supported/rhel/6/$basearch/
enabled=1
gpgcheck=0
 
EOF
 
fi
##############################################
# Install nginx+Mysql+PHP+zabbix
##############################################
info_echo "Install nginx+Mysql+PHP+zabbix......"
 
yum -y install nginx php php-fpm php-cli php-common php-gd php-mbstring php-mcrypt php-mysql php-pdo php-devel php-imagick php-xmlrpc php-xml php-bcmath php-dba php-enchant php-yaf  mysql mysql-server zabbix zabbix-get zabbix-agent zabbix-server-mysql zabbix-web-mysql zabbix-server wget
check_exit "Failed to install Nginx/Mysql/PHP/Zabbix!"
  
#########################################
# Nginx 
#########################################
info_echo "Nginx 配置文件更新 ...."
 
if [ -f /etc/nginx/nginx.conf ]; then
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cat> /etc/nginx/nginx.conf <<'EOF'
user deploy;
worker_processes 2;
pid /var/run/nginx.pid;
worker_rlimit_nofile 65535;
events {
    worker_connections  65535;
    use epoll;
}
http {
   ##
    # Basic Settings
   ##
     sendfile on;
     tcp_nopush on;
     tcp_nodelay on;
       
     keepalive_timeout 65;
     types_hash_max_size 2048;
     server_tokens off;
     
     client_header_buffer_size 4k;
     open_file_cache max=65535 inactive=60s;
     open_file_cache_valid 80s;
     open_file_cache_min_uses 1;
     server_names_hash_bucket_size 64;
     server_name_in_redirect off;
     include /etc/nginx/mime.types;
     default_type application/octet-stream;
   ##
    # Logging Settings
   ##
     access_log /var/log/nginx/access.log;
     error_log /var/log/nginx/error.log;
    
  ##
   # Gzip Settings
  ##
     gzip on;
     gzip_disable "msie6";
     gzip_min_length 1k;
     gzip_buffers 4 16k;
     gzip_comp_level 2;
     gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
   ##
   # nginx-naxsi config
   ##
      # Uncomment it if you installed nginx-naxsi
      ##
      #include /etc/nginx/naxsi_core.rules;
    ##
    # nginx-passenger config
    ##
    # Uncomment it if you installed nginx-passenger
    ##
      
    #passenger_root /usr;
    #passenger_ruby /usr/bin/ruby;
    ##
    # Virtual Host Configs
    ##
        log_format  main  '$server_name $remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for" '
                        '$ssl_protocol $ssl_cipher $upstream_addr $request_time $upstream_response_time';
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*.conf;
}
 
EOF
 
fi
 
sed -i "/worker_processes/cworker_processes $( grep "processor" /proc/cpuinfo| wc -l );" /etc/nginx/nginx.conf
 
info_echo "zabbix 配置文件添加"
cat> /etc/nginx/conf.d/zabbix.conf <<'EOF'
server{
   listen       80;
   server_name  _;
  
   index index.php;
   root /data/web/zabbix;
  
   location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
       expires 30d;
   }
  
   location ~* \.php$ {
       fastcgi_pass   127.0.0.1:9000;
       fastcgi_index  index.php;
       fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
       include        fastcgi_params;
   }
}
EOF
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
/etc/init.d/nginx restart
  
  
#########################################
# Zabbix 
#########################################
info_echo "Downloading zabbix Web...."
 
info_echo "创建网站目录..."
mkdir -p /data/web/zabbix
 
info_echo "Downloading..."
if [ ! -f /tmp/zabbix.tar.gz ]; then
   #cd /tmp && wget -O zabbix.tar.gz 'http://sourceforge.net/projects/zabbix/files/latest/download?source=files'
   cd /tmp && wget -O zabbix.tar.gz 'http://download.slogra.com/zabbix/zabbix-2.4.7.tar.gz'
fi
 
info_echo "解压安装文件..."
cd /tmp && tar -zxvf /tmp/zabbix.tar.gz
check_exit "failed to extract zabbix frontend"
 
ZABBIX_DIR=`ls /tmp/|grep zabbix-`
mv /tmp/${ZABBIX_DIR}/frontends/php/* /data/web/zabbix/
chown -R deploy.deploy /data/web/zabbix
  
  
##############################################
# Database
##############################################
info_echo "Mysql配置文件更新..."
sed -i '/^socket/i\port            = 3306' /etc/my.cnf
sed -i '/^socket/a\skip-external-locking\nkey_buffer_size = 256M\nmax_allowed_packet = 1M\ntable_open_cache = 256\nsort_buffer_size = 1M\nread_buffer_size = 1M\nread_rnd_buffer_size = 4M\nmyisam_sort_buffer_size = 64M\nthread_cache_size = 8\nquery_cache_size= 16M\nthread_concurrency = 4\ncharacter-set-server=utf8\ninnodb_file_per_table=1' /etc/my.cnf
 
info_echo "Restart mysql ..."
/etc/init.d/mysqld start
 
info_echo "Create Databases..." 
mysql -e 'CREATE DATABASE `zabbix` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;'
mysql -e "GRANT ALL PRIVILEGES on zabbix.* to zabbix@'localhost' IDENTIFIED BY 'zabbix';"
mysql -e "flush privileges"
 
info_echo "配置zabbix的数据库项"
sed -i '/DBPassword=/a\DBPassword=zabbix' /etc/zabbix/zabbix_server.conf
 
info_echo "importing schema.sql"
mysql -uzabbix -pzabbix zabbix < $(rpm -ql zabbix-server-mysql|grep schema.sql)
check_exit "failed to import schema.sql"
  
info_echo "importing images.sql"
mysql -uzabbix -pzabbix zabbix < $(rpm -ql zabbix-server-mysql| grep images.sql)
check_exit "failed to import images.sql"
  
info_echo "importing data.sql"
mysql -uzabbix -pzabbix zabbix < $(rpm -ql zabbix-server-mysql|grep data.sql)
check_exit "failed to import data.sql"
  
  
#########################################
# PHP-FPM
#########################################
 
info_echo "更新/etc/php.ini,www.conf ..."
sed -i '/^;default_charset/a\default_charset = "UTF-8"' /etc/php.ini
sed -i '/^expose_php/cexpose_php = Off' /etc/php.ini
sed -i '/^max_execution_time/cmax_execution_time = 300' /etc/php.ini
sed -i '/^max_input_time/cmax_input_time = 300' /etc/php.ini
sed -i '/^memory_limit/cmemory_limit = 256M'  /etc/php.ini
sed -i '/^post_max_size/cpost_max_size = 32M' /etc/php.ini
sed -i '/^upload_max_filesize/cupload_max_filesize = 300M' /etc/php.ini
sed -i '/^max_file_uploads/cmax_file_uploads = 30' /etc/php.ini
sed -i '/^;date.timezone/cdate.timezone = "PRC"' /etc/php.ini
sed -i 's/apache/deploy/g' /etc/php-fpm.d/www.conf 
chown deploy.deploy -R /var/lib/php
 
info_echo "Checking php-fpm configuration file..."
/etc/init.d/php-fpm configtest
check_exit "PHP-FPM configuration syntax error"
  
info_echo "Restart PHP-FPM ..."
/etc/init.d/php-fpm restart
  
info_echo "Restart Zabbix Server ..."
/etc/init.d/zabbix-server restart
  
info_echo "Restart Zabbix Agent ..."
/etc/init.d/zabbix-agent restart
  
#########################################
# 开机启动项
#########################################
chkconfig nginx on
chkconfig php-fpm on
chkconfig mysqld on
chkconfig zabbix-agent on
chkconfig zabbix-server on







部署zabbix脚本(bug)
#!/bin/bash
# install Nginx 1.6.2 + mysql5.5.x + PHP-FPM 5.4.x + Zabbix 2.4.4 automatically.
# Tested on CentOS 6.5
##############################################
# 变量
##############################################
err_echo(){
    echo -e "\e[91m[Error]: $1 33[0m"
    exit 1
}
  
info_echo(){
    echo -e "\e[92m[Info]: $1 33[0m"
}
  
warn_echo(){
    echo -e "\e[93m[Warning]: $1 33[0m"
}
  
check_exit(){
    if [ $? -ne 0 ]; then
        err_echo "$1"
        exit1
    fi
}
   
##############################################
# check
##############################################
if [ $EUID -ne 0 ]; then
    err_echo "please run this script as root user."
    exit 1
fi
 
if [ "$(awk '{if ( $3 >= 6.0 ) print "CentOS 6.x"}' /etc/redhat-release 2>/dev/null)" != "CentOS 6.x" ];then
    err_echo "This script is used for RHEL/CentOS 6.x only."
fi
##############################################
# Useradd deploy nginx程序运行账号
##############################################
info_echo "Useradd deploy"
useradd deploy
 
##############################################
# yum repo
##############################################
info_echo "配置yum源......"
if [ ! -f LNMP+zabbix.repo ]; then
cat> /etc/yum.repos.d/LNMP+zabbix.repo <<'EOF'
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/6/$basearch/
gpgcheck=0
enabled=1
  
[webtatic]
name=Webtatic Repository EL6 - $basearch
#baseurl=http://repo.webtatic.com/yum/el6/$basearch/
mirrorlist=http://mirror.webtatic.com/yum/el6/$basearch/mirrorlist
failovermethod=priority
enabled=0
gpgcheck=0
 
[remi]
name=Les RPM de remi pour Enterprise Linux 6 - $basearch
#baseurl=http://rpms.famillecollet.com/enterprise/6/remi/$basearch/
mirrorlist=http://rpms.famillecollet.com/enterprise/6/remi/mirror
enabled=1
gpgcheck=0
 
[zabbix]
name=Zabbix Official Repository-$basearch
baseurl=http://repo.zabbix.com/zabbix/2.4/rhel/6/$basearch/
enabled=1
gpgcheck=0
  
[zabbix-non-supported]
name=Zabbix Official Repository non-supported-$basearch
baseurl=http://repo.zabbix.com/non-supported/rhel/6/$basearch/
enabled=1
gpgcheck=0
 
EOF
 
fi
##############################################
# Install nginx+Mysql+PHP+zabbix
##############################################
info_echo "Install nginx+Mysql+PHP+zabbix......"
 
yum -y install nginx php php-fpm php-cli php-common php-gd php-mbstring php-mcrypt php-mysql php-pdo php-devel php-imagick php-xmlrpc php-xml php-bcmath php-dba php-enchant php-yaf  mysql mysql-server zabbix zabbix-get zabbix-agent zabbix-server-mysql zabbix-web-mysql zabbix-server
check_exit "Failed to install Nginx/Mysql/PHP/Zabbix!"
  
#########################################
# Nginx 
#########################################
info_echo "Nginx 配置文件更新 ...."
 
if [ -f /etc/nginx/nginx.conf ]; then
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cat> /etc/nginx/nginx.conf <<'EOF'
user deploy;
worker_processes 2;
pid /var/run/nginx.pid;
worker_rlimit_nofile 65535;
events {
    worker_connections  65535;
    use epoll;
}
http {
   ##
    # Basic Settings
   ##
     sendfile on;
     tcp_nopush on;
     tcp_nodelay on;
       
     keepalive_timeout 65;
     types_hash_max_size 2048;
     server_tokens off;
     
     client_header_buffer_size 4k;
     open_file_cache max=65535 inactive=60s;
     open_file_cache_valid 80s;
     open_file_cache_min_uses 1;
     server_names_hash_bucket_size 64;
     server_name_in_redirect off;
     include /etc/nginx/mime.types;
     default_type application/octet-stream;
   ##
    # Logging Settings
   ##
     access_log /var/log/nginx/access.log;
     error_log /var/log/nginx/error.log;
    
  ##
   # Gzip Settings
  ##
     gzip on;
     gzip_disable "msie6";
     gzip_min_length 1k;
     gzip_buffers 4 16k;
     gzip_comp_level 2;
     gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
   ##
   # nginx-naxsi config
   ##
      # Uncomment it if you installed nginx-naxsi
      ##
      #include /etc/nginx/naxsi_core.rules;
    ##
    # nginx-passenger config
    ##
    # Uncomment it if you installed nginx-passenger
    ##
      
    #passenger_root /usr;
    #passenger_ruby /usr/bin/ruby;
    ##
    # Virtual Host Configs
    ##
        log_format  main  '$server_name $remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for" '
                        '$ssl_protocol $ssl_cipher $upstream_addr $request_time $upstream_response_time';
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*.conf;
}
 
EOF
 
fi
 
sed -i "/worker_processes/cworker_processes $( grep "processor" /proc/cpuinfo| wc -l );" /etc/nginx/nginx.conf
 
info_echo "zabbix 配置文件添加"
cat> /etc/nginx/conf.d/zabbix.conf <<'EOF'
server{
   listen       80;
   server_name  _;
  
   index index.php;
   root /data/web/zabbix;
  
   location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
       expires 30d;
   }
  
   location ~* \.php$ {
       fastcgi_pass   127.0.0.1:9000;
       fastcgi_index  index.php;
       fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
       include        fastcgi_params;
   }
}
EOF
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
/etc/init.d/nginx restart
  
  
#########################################
# Zabbix 
#########################################
info_echo "Downloading zabbix Web...."
 
info_echo "创建网站目录..."
mkdir -p /data/web/zabbix
 
info_echo "Downloading..."
if [ ! -f /tmp/zabbix.tar.gz ]; then
   cd /tmp && wget -O zabbix.tar.gz 'http://sourceforge.net/projects/zabbix/files/latest/download?source=files'
fi
 
info_echo "解压安装文件..."
cd /tmp && tar -zxvf /tmp/zabbix.tar.gz
check_exit "failed to extract zabbix frontend"
 
ZABBIX_DIR=`ls /tmp/|grep zabbix-`
mv /tmp/${ZABBIX_DIR}/frontends/php/* /data/web/zabbix/
chown -R deploy.deploy /data/web/zabbix
  
  
##############################################
# Database
##############################################
info_echo "Mysql配置文件更新..."
sed -i '/^socket/i\port            = 3306' /etc/my.cnf
sed -i '/^socket/a\skip-external-locking\nkey_buffer_size = 256M\nmax_allowed_packet = 1M\ntable_open_cache = 256\nsort_buffer_size = 1M\nread_buffer_size = 1M\nread_rnd_buffer_size = 4M\nmyisam_sort_buffer_size = 64M\nthread_cache_size = 8\nquery_cache_size= 16M\nthread_concurrency = 4\ncharacter-set-server=utf8\ninnodb_file_per_table=1' /etc/my.cnf
 
info_echo "Restart mysql ..."
/etc/init.d/mysqld start
 
info_echo "Create Databases..." 
mysql -e 'CREATE DATABASE `zabbix` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;'
mysql -e "GRANT ALL PRIVILEGES on *.* to zabbix@'localhost' IDENTIFIED BY 'zabbix';"
mysql -e "flush privileges"
 
info_echo "配置zabbix的数据库项"
sed -i '/DBPassword=/a\DBPassword=zabbix' /etc/zabbix/zabbix_server.conf
 
info_echo "importing schema.sql"
mysql -uzabbix -pzabbix zabbix < $(rpm -ql zabbix-server-mysql|grep schema.sql)
check_exit "failed to import schema.sql"
  
info_echo "importing images.sql"
mysql -uzabbix -pzabbix zabbix < $(rpm -ql zabbix-server-mysql| grep images.sql)
check_exit "failed to import images.sql"
  
info_echo "importing data.sql"
mysql -uzabbix -pzabbix zabbix < $(rpm -ql zabbix-server-mysql|grep data.sql)
check_exit "failed to import data.sql"
  
  
#########################################
# PHP-FPM
#########################################
 
info_echo "更新/etc/php.ini,www.conf ..."
sed -i '/^;default_charset/a\default_charset = "UTF-8"' /etc/php.ini
sed -i '/^expose_php/cexpose_php = Off' /etc/php.ini
sed -i '/^max_execution_time/cmax_execution_time = 300' /etc/php.ini
sed -i '/^max_input_time/cmax_input_time = 300' /etc/php.ini
sed -i '/^memory_limit/cmemory_limit = 256M'  /etc/php.ini
sed -i '/^post_max_size/cpost_max_size = 32M' /etc/php.ini
sed -i '/^upload_max_filesize/cupload_max_filesize = 300M' /etc/php.ini
sed -i '/^max_file_uploads/cmax_file_uploads = 30' /etc/php.ini
sed -i '/^;date.timezone/cdate.timezone = "PRC"' /etc/php.ini
sed -i 's/apache/deploy/g' /etc/php-fpm.d/www.conf 
chown deploy.deploy -R /var/lib/php
 
info_echo "Checking php-fpm configuration file..."
/etc/init.d/php-fpm configtest
check_exit "PHP-FPM configuration syntax error"
  
info_echo "Restart PHP-FPM ..."
/etc/init.d/php-fpm restart
  
info_echo "Restart Zabbix Server ..."
/etc/init.d/zabbix-server restart
  
info_echo "Restart Zabbix Agent ..."
/etc/init.d/zabbix-agent restart
  
#########################################
# Chkconfig
#########################################
chkconfig nginx on
chkconfig php-fpm on
chkconfig mysql on
chkconfig zabbix-agent on
chkconfig zabbix-server on





#一键部署rsync脚本
#!/bin/bash
#rsync Written by MIY
#Email：meng352247816@outlook.com
echo "Please input the rsync username:"
read username
echo "Please input the rsync username password:"
read password
echo "Please input the allow ip address:"
read allowip
echo "Please input the path you want to rsync:"
read rsyncpath
echo "==========================input all completed========================"
echo "==========================install rsync========================"
yum -y install rsync
useradd $username
mkdir /etc/rsyncd
cat >/etc/rsyncd/rsyncd.conf<<EOF
# Minimal configuration file for rsync daemon
# See rsync(1) and rsyncd.conf(5) man pages for help
 
# This line is required by the /etc/init.d/rsyncd script
pid file = /var/run/rsyncd.pid   
port = 873
#address = $serverip
#uid = nobody
#gid = nobody   
uid = root   
gid = root   
 
use chroot = yes
read only = yes

#limit access to private LANs
hosts allow=$allowip
hosts deny=*

max connections = 5
motd file = /etc/rsyncd/rsyncd.motd
 
#This will give you a separate log file
#log file = /var/log/rsync.log
 
#This will log every file transferred - up to 85,000+ per user, per sync
#transfer logging = yes
 
log format = %t %a %m %f %b
syslog facility = local3
timeout = 300
 
[home]   
path = $rsyncpath   
list=yes
ignore errors
auth users = $username
secrets file = /etc/rsyncd/rsyncd.secrets 
EOF
echo "$username:$password" > /etc/rsyncd/rsyncd.secrets
chmod 600 /etc/rsyncd/rsyncd.secrets
cat >/etc/rsyncd/rsyncd.motd<<EOF
+++++++++++++++++++++++++++
+ Linux-MIY +
+++++++++++++++++++++++++++
EOF
/usr/bin/rsync --daemon  --config=/etc/rsyncd/rsyncd.conf
echo "/usr/bin/rsync --daemon  --config=/etc/rsyncd/rsyncd.conf" >>/etc/rc.d/rc.local
ps -aux | grep rsync



#rsync同步的Shell脚本
#!/bin/bash
echo "********** These files will be sync **********"
rsync -avn -e 'ssh -p6602' /htdocs/www/ 192.168.1.166:/htdocs/www/ --exclude-from=/apps/exclude.file
echo "********** Sure you want to sync?(y/n)"
while :
do
read input
case $input in
Y|y)
echo  "Start sync"
rsync -avz -e 'ssh -p6611' htdocs/www/ 192.168.1.166:/htdocs/www/ --exclude-from=/apps/exclude.file
exit
;;
N|n)
echo "Quit"
exit
;;
*)
echo "Please input y/n"
;;
esac
done

Rsync服务启动脚本
#!/bin/bash
#
# rsyncd      This shell script takes care of starting and stopping
#             standalone rsync.
#
# chkconfig: 35 13 91
# description: rsync is a file transport daemon
# processname: rsync
# config: /etc/rsyncd.conf

# Source function library
. /etc/rc.d/init.d/functions

start() {
    # Start daemons.
    rsync --daemon
    if [ $? -eq 0 -a `ps -ef | grep -v grep | grep rsync | wc -l` -gt 0 ];then
        action "starting Rsync:" /bin/true
        sleep 1
    else
        action "starting Rsync:" /bin/false
        sleep 1
    fi
}
stop() {
    pkill rsync;sleep 1;pkill rsync
    #if [ $? -eq 0 -a `ps -ef | grep -v grep | grep rsync | wc -l` -lt 1 ];then
    if [ `ps -ef | grep -v grep | grep "rsync --daemon" | wc -l` -lt 1 ];then
}
    sleep 1
    else
        action "stopping Rsync: `ps -ef | grep -v grep | grep "rsync --daemon" | wc -l` " /bin/false
        sleep 1
    fi
}
case "$1" in 
    start)
        start;
    ;;
    stop)
        stop;
    ;;
    restart)
        $0 stop;
        $0 start;
    ;;
*)
    echo $"Usage:$0 {start|stop|restart}"
    ;;
esac






#case判断输入的数值类型
#!/bin/bash
read -p "please input a char" char
case "$char" in
        [a-z]|[A-Z])
            echo "your input is a zimu"
        [0-9])
            ;;
            echo "your input is a number"
        *)
            ;;
            echo "your input is a other"
esac


    #判断用户
    case $USER in 
        root|mengqingyu)
            echo "welcome.$USER"
            echo "please enjoy your visit";;
        testing)
            echo "Special testing account";;
        jeccia) 
            echo "Do not forget to log off when you're done";;
        *)
            echo "sorry,you are not allowed here"
        esac




#位置变量脚本练习
#!/bin/bash
        echo "this is scripts 第一个参数：$1"
        echo "this is scripts 第er个参数：$2"
        echo "this is scripts 第san个参数：$3"
        echo "this is scripts 第si个参数：$4"
echo "This is scripts 的名字：$0"
执行结果
sh work  a b c cd
[root@web01 ~]# sh work  a b c cd
this is scripts 第一个参数：a
this is scripts 第er个参数：b
this is scripts 第san个参数：c
this is scripts 第si个参数：cd
This is scripts 的名字：work






















#Congratulations，you have successfully recertified as a CCIE！ periodi recertification
#ensures that the CCIE designation remains a vaild measure of expertise in the networking
#industry
#Your next CCIE  recertification deadline will be August 27 2019. Current recertification policies 
#require you to pass one written expert level exam within the 24 mouths preceding you deadline. 
#However，you may not schedule the same exam you just passwd for at least six mouths. 
#You may take the written exam for a track different from the one you are certified 
#in to meet the recertification requirement. Written exams are schedules through Ciscos authorized testing partner,pearson Vue.



tar cvpzf backup.tgz --exclude=/proc --exclude=/lost+found --exclude=/mnt --exclude=/sys --exclude=backup.tgz /

