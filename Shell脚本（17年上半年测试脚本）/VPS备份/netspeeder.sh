#!/bin/sh

# Set Linux PATH Environment Variables
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check If You Are Root
if [ $(id -u) != "0" ]; then
    clear
    echo -e "\033[31m Error: You must be root to run this script! \033[0m"
    exit 1
fi

SysName='';
egrep -i "centos" /etc/issue && SysName='centos';
egrep -i "debian" /etc/issue && SysName='debian';
egrep -i "ubuntu" /etc/issue && SysName='ubuntu';


if [ $(arch) == x86_64 ]; then
    OSB=x86_64
elif [ $(arch) == i686 ]; then
    OSB=i386
else
    echo "\033[31m Error: Unable to Determine OS Bit. \033[0m"
    exit 1
fi
if egrep -q "5\." /etc/issue; then
    OST=5
    wget http://dl.fedoraproject.org/pub/epel/5/${OSB}/epel-release-5-4.noarch.rpm
elif egrep -q "6\." /etc/issue; then
    OST=6
    wget http://dl.fedoraproject.org/pub/epel/6/${OSB}/epel-release-6-8.noarch.rpm
else
    echo "\033[31m Error: Unable to Determine OS Version. \033[0m"
    exit 1
fi

rpm -Uvh epel-release*rpm
yum install -y libnet libnet-devel libpcap libpcap-devel gcc

wget http://net-speeder.googlecode.com/files/net_speeder-v0.1.tar.gz -O -|tar xz
cd net_speeder
if [ -f /proc/user_beancounters ] || [ -d /proc/bc ]; then
    sh build.sh -DCOOKED
    INTERFACE=venet0
else
    sh build.sh
    INTERFACE=eth0
fi

NS_PATH=/usr/local/netspeeder
mkdir -p $NS_PATH
cp -Rf net_speeder $NS_PATH/net_speeder

echo "#!/bin/bash
#chkconfig: 345 85 15
#description: netspeeder start script.
### BEGIN INIT INFO
# Provides:          LZH
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: The NetSpeeder
### END INIT INFO

start() {
	nohup ${NS_PATH}/net_speeder $INTERFACE \"ip\" >/dev/null 2>&1 &
	echo 'NetSpeeder Started!';
}

stop() {
	sync;
	for PID in \`ps aux|grep -E 'net_speeder'|grep -v grep|awk '{print \$2}'\`; do
		kill -s 9 \$PID >/dev/null;
	done;
	echo 'NetSpeeder Stoped!';
}

case \"\$1\" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	*)
		echo \$\"Usage: \$prog {start|stop|restart}\"
		exit 1
esac">/etc/rc.d/init.d/netspeederd
chmod 775 /etc/rc.d/init.d/netspeederd

if [ "$SysName" == 'centos' ]; then
	chkconfig netspeederd on;
else
	update-rc.d -f netspeederd defaults;
fi;

cd ..
rm -rf epel-release-5-4.noarch.rpm epel-release-6-8.noarch.rpm epel-release-5-4.noarch.rpm net_speeder

service netspeederd start
echo -e "\033[36m net_speeder installed. \033[0m"





IPT="/sbin/iptables"
$IPT --delete-chain
$IPT --flush
$IPT -P INPUT DROP    
$IPT -P FORWARD DROP  
$IPT -P OUTPUT DROP   
$IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
$IPT -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
$IPT -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT 
$IPT -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT  
$IPT -A INPUT -p tcp -m tcp --dport 873 -j ACCEPT 
$IPT -A INPUT -i lo -j ACCEPT 
$IPT -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT 
$IPT -A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT 
$IPT -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
$IPT -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT 
$IPT -A OUTPUT -o lo -j ACCEPT 
$IPT -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT 
$IPT -A OUTPUT -p tcp -m tcp --dport 25 -j ACCEPT 
$IPT -A OUTPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT  
$IPT -A OUTPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT 
service iptables save
service iptables restart





设置INPUT,FORWARD,OUTPUT链默认target为DROP，也就是外部与服务器不能通信。
设置当连接状态为RELATED和ESTABLISHED时，允许数据进入服务器。
设置外部客户端连接服务器端口80,22,21,873。
允许内部数据循回。
允许外部ping服务器 。
设置状态为RELATED和ESTABLISHED的数据可以从服务器发送到外部。
允许服务器使用外部dns解析域名。
设置服务器连接外部服务器端口80。
允许服务器发送邮件。
允许从服务器ping外部。





vi /root/iptables/blocked.ip
192.168.1.0/24
#!/bin/bash
# 禁止指定 IP/subnet 的shell 脚本
# -------------------------------
IPT=/sbin/iptables
SPAMLIST="spamlist"
SPAMDROPMSG="SPAM LIST DROP"
BADIPS=$(egrep -v -E "^#|^$" /root/iptables/blocked.ips)
 
# 创建new iptables列表
$IPT -N $SPAMLIST
 
for ipblock in $BADIPS
do
   $IPT -A $SPAMLIST -s $ipblock -j LOG --log-prefix "$SPAMDROPMSG"
   $IPT -A $SPAMLIST -s $ipblock -j DROP
done
 
$IPT -I INPUT -j $SPAMLIST
$IPT -I OUTPUT -j $SPAMLIST
$IPT -I FORWARD -j $SPAMLIST






#/bin/bash
wget -O /tmp/kr.zone http://www.ipdeny.com/ipblocks/data/countries/kr.zone
for ip in `cat /tmp/kr.zone`
do
iptables -I INPUT -s $ip -j DROP
done






#!/bin/bash
#
this_path=$(cd `dirname $0`;pwd)   #根据脚本所在路径
cd $this_path   
echo $this_path  
current_date=`date -d "-1 day" "+%Y%m%d"`   #列出时间
echo $current_date  
split -b 60m -d -a 4 ./nohup.out   ./logs/nohup-${current_date}  #切分60兆每块至logs文件中，格式为：nohup-xxxxxxxxxx        
cat /dev/null > nohup.out#清空当前目录的nohup.out文件






crontab -e
 * * * * */1 /cljj/apps/21.biz_channel/clearNohup.sh

#!/bin/sh
#定义变量生成昨天的日期
yesterday=`TZ=aaa24 date +%Y%m%d`
#将nohup日志按日期输出并清空当前日志
cp /weblogic/Log/nohup.log /weblogic/Log/nohup${yesterday}.log
cat /dev/null > /weblogic/Log/nohup.log
#保留最近7天的日志
cd /weblogic/Log
find ./ -ctime +7 -name "nohup*.log" |xargs rm


 kernel /boot/vmlinuz-2.4.20-selinux-2003040709 ro root=/dev/hda1 nousb selinux=0
    ...



 nohup ./station　>>station_`date +%Y%m%d%H%M`.log 