#!/bin/bash
#auto drop ssh failed IP address
#by authors Linux-大牙 2017-6-29
#定义变量
SEC_FILE=/var/log/secure
#下面是为了截获secure文件恶意攻击的IP远程登录22端口，大于等于4次后就写入到防火墙里，直接拉黑，禁止后再登录服务器的22端口,egrep -o "([0-9{1,3\.}]){3}[0-9]{1,3}"是配置IP的意思，[0-9]表示任意一个数，{1,3}表示匹配1-3次
IP_ADDR=`tail -n 100 /var/log/secure |grep "Failed password"| egrep -o "([0-9{1,3\.}]){3}[0-9]{1,3}" | sort -nr | uniq -c | awk ' $1>=4 {print $2}'`
IPTABLE_CONF=/etc/sysconfig/iptables
for i in `echo $IP_ADDR`
do
#查看iptables配置文件是否含有提取的IP信息
        cat $IPTABLES_CONF |grep $i >/dev/null
if
        [ $? -ne 0 ];then
#判断iptables配置文件里是否存在已拒绝的ip，如果不存在，就不再添加相应条目，sed a参数的意思是配置之后加入的行，比如你的防火墙规则里有一条-A INPUT -i lo -j ACCEPT,他的意思就>说在这一条规则的后面添加。
        sed -i "lo/a -A INPUT -s $i -m state --state NEW -m tcp -p tcp --dport 22 -j DROP" $IPTABLES_CONF
else
#如果存在的话，那就显示提示信息
        echo "This is $i is exist in iptables,please exit ....."
fi
done
#最后重启
/etc/init.d/iptables restart







#!/bin/bash
#auto drop ssh failed IP address
#by authors Linux-大牙 2017-6-29
cat /var/log/secure |awk '/Failed/ {print $()}' | sort | uniq -c | awk '{print $2"="$1;}' > /usr/local/bin/black.list
for i in `cat //usr/local/bin/black.list`
do
        if IP=`echo $i | awk -F= '{print $1}'`
        NUM= `echo $i | awk -F= '{print $1}'`
if   [$ {#NUM} -gt 1]; then
        echo "sshd:$IP:deny"  >> /etc/hosts/deny       
        fi

done






#!/bin/bash
#auto drop ssh failed IP address
#by authors Linux-MIY 2017-6-29
cat /var/log/secure | awk '/Failed/ {print $(NF-3)}' | sort | uniq -c | awk '{print $2"="$1;}' > /usr/local/bin/black.list
for i in `cat /usr/local/bin/black.list`
do
           IP=`echo $i | awk -F = '{print $1}'`
           NUM=`echo $i | awk -F = '{print $2}'`
if [ ${#NUM} -gt 1 ];then
        grep $IP /etc/hosts.deny > /dev/null
if [ $? -gt 0 ];then
        echo "sshd:$IP:deny" >> /etc/hosts.deny

fi

fi


done









#!/bin/bash
#Capture_status - Gather System Performance Statics
##################################################
#Set Scripts Variables
#$REPORT_FILE=/var/systemreport/report.csv
MAIL= mail -s "system moperation status" root
DATE=`date +%m/%d/%y`
TIME=`date +%k:%m:%s`
#
##################################################
USERS=`uptime | sed 's/users.*$//' | gawk '{print $NF}'`
LOAD=`uptime | gawk '{print $NF}'`
FREE=`vmstat 1 2 | sed -n '/[0-9]/p' |  sed -n '2p'` |
gawk '{print $4}'
IDLE=`vmstat 1 2 | sed -n '/[0-9]/p' |  sed -n '2p'` |
gawk '{print $15}'
#
##################################################
# Send  system moperation status  to  mail
#
echo "$DATE.$TIME.$USERS.$LOAD.$FREE.$IDLE"  | mail -s "system"  root






#!/bin/bash
REPORT_FILE=/var/systemreport/report.csv
TEMP_FILE=/var/systemreport/webreport.html
#
DATE=`date +%m/%d/%Y`
MAIL_TO=root

echo "<html><body><h2>Report for $DATE</h2>" >$TEMP_FILE
echo "<table border=\"1\">" >> $TEMP_FILE
echo "<tr>load</td><td>Free memory</td><td>%cpu IDLE</td><tr>" >> $TEMP_FILE

cat $REPORT_FILE  | gwak -F .'{
printf "<tr><td>%s</td><td>%s</td><td>%s</td>". $1.$2.$3:
printf "<td>%s</td><td>%s</td><td>%s</td>\n</tr>\n". $4.$5.$6:
}' >> $TEMP_FILE
echo "</table></body></html>" >> $TEMP_FILE
mail -a $TEMP_FILE -s "Performance Report $DATE" --$MAIL_TO  < /dev/null
rm -f $TEMP_FILE

