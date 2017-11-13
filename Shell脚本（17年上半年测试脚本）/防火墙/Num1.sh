IPTABLES=/sbin/iptables
MODPROBE=/sbin/modprobe
INT_NET=192.168.136.122/24
echo "[+]Flushing existing iptables rules......"
IPTABLES -F 
IPTABLES -F -t nat
IPTABLES -X  
IPTABLES -P INPUT DROP
IPTABLES -P OUTPUT DROP
IPTABLES -P FORWARD DROP
#####load connection-tracking modules 
$MODPROBE ip_conntrack 
$MODPROBE iptable_nat
$MODPROBE ip_conntrack_ftp
$MODPROBE ip_nat_ftp
###INPUT chain######
echo "[+] Setting  up INPUT chain "
###state tracking  rules## 
$IPTABLES -A INPUT -m state --state INVAILD -j LOG --log-prefix "DROP INVAIlD"  
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
### anti-spoofing rules ##
$IPTABLES -A INPUT -i ens33 -s ! $INT_NET -j LOG --log-prefix "SPOOFED PKT"  
$IPTABLES -A INPUT -i ens33 -s ! $INT_NET -j DROP
##ACCEPT rules##
$IPTABLES -A INPUT -i ens33  -p tcp -s $INT_NET --dport 22 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A INPUT -p  icmp --icmp-type echo request -j ACCEPT 
##default INPUT LOG rule ##
$IPTABLES -A INPUT -i ! lo -j --log-prefix "DROP" --log-ip-options -- log-tcp-options
##OUTPUT chain##
echo "[+] Setting up OUTPUT chain..."
#state tracking rules#
$IPTABLES -A OUTPUT -m state --state INVAILD -j LOG --log-prefix "DROP INVAILD" --log-ip-options --log-tcp-options
$IPTABLES -A OUTPUT -m state --state INVAILD -j DROP 
$IPTABLES -A OUTPUT -m state --state ESTABLISHED,RELATED, -j ACCEPT 
##ACCEPT rules for allowing connections out
$IPTABLES -A OUTPUT -p tcp --dropt 22 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dropt 21 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dropt 25 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dropt 43 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dropt 80 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dropt 443 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dropt 4321 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dropt 53 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type echo request -j ACCEPT 
##Default OUTPUT LOG rule
$IPTABLES -A OUTPUT -o ! lo -j LOG --log-prefix "DROP"  --log-ip-options --log-tcp-options
##FORWARD chain##
echo "[+] Setting up FORWARD chain...."
##state tracking rules
$IPTABLES -A FORWARD -m state --state INVAILD -j LOG --log-prefix "DROP"
INVAILD " --log-ip-options --log-tcp-options"
$IPTABLES -A FORWARD -m state --state INVAILD -j DROP
$IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
##anti-spoofing rules
$IPTABLES -A -i eth3 -s ! $INT_NET -j LOG --log-prefix "SPOOFED PKT"
$IPTABLES -A -i eth3 -s ! $INT_NET -j DROP
#ACCEPT rules 
$IPTABLES -A FORWARD -p tcp -i ens33 -s $INT_NET -dport 21 --syn -m state --state NEW -j ACCEPT 
$IPTABLES -A FORWARD -p tcp -i ens33 -s $INT_NET -dport 22 --syn -m state --state NEW -j ACCEPT 
$IPTABLES -A FORWARD -p tcp -i ens33 -s $INT_NET -dport 25 --syn -m state --state NEW -j ACCEPT 
$IPTABLES -A FORWARD -p tcp -i ens33 -s $INT_NET -dport 43 --syn -m state --state NEW -j ACCEPT 
$IPTABLES -A FORWARD -p tcp -i ens33 -s $INT_NET -dport 21 --syn -m state --state NEW -j ACCEPT 
$IPTABLES -A FORWARD -p udp --dport 53 -m state --state  NEW -j ACCEPT
##DEFAULT log rule
$IPTABLES -A FORWARD -i ! lo -j LOG --log-prefix "DROP" --log-ip-options --log-tcp-options
##NAT rules##
echo "[+] Setting up  NAT rules" 
$IPTABLES -t nat -A PRETOUTING -p tcp --dport 80 -i eth3 -j DNAT --to 192.168.0.100:80
$IPTABLES -t nat -A PRETOUTING -p tcp --dport 43 -i eth3 -j DNAT --to 192.168.0.100:43
$IPTABLES -t nat -A PRETOUTING -p tcp --dport 53 -i eth3 -j DNAT --to 192.168.0.100:53
$IPTABLES -t nat -A PRETOUTING -p tcp -s  $INT_NET -o eth3 -j MASQUERADE



iptables -P FORWARD DROP
    for mac in $(cat ipaddressfile); do
    iptables -A FORWARD -m mac --mac-source $mac -j ACCEPT
done 









#清除规则
iptables -F
iptables -X
iptables -Z
#设定政策
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
#制定各项规则
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth3   -m state --state RELATED =,ESTABLISHED -j ACCEPT
#iptables -A INPUT  -i eth3 -s 192.168.5.1/24 -j ACCEPT
#写入防火墙配置文件
service iptables restart
#/etc/init.d/iptables save


#!/bin/bash
EXEIF="eth3"
INIF="eth1"
INNET="192.168.100.0/24" 若无内部网络接口，请填写成INNET=""
export EXEIF INIF INNET
##设定核心功能##
echo "1" >> /proc/sys/net/ipv4/tcp_syncookies
echo "1" >> /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
for i in /proc/sys/net/ipv4/conf/*/{rp_filter,log_martians};
do
 echo "1" > $i
 done 
 for i in /proc/sys/ipv4/conf/*/{accept_source_route,accept_redirects,send_redirects};
 do 
 echo "0" >$i
done
##清除规则，设定默认政策及开放lo与相关的设定值
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin;
export PATH
iptables -F
iptables -X
iptables -Z
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
3. 启动额外的防火墙 script 模块
if [ -f /usr/local/virus/iptables/iptables.deny ];
then
sh /usr/local/virus/iptables/iptables.deny
fi
if [ -f /usr/local/virus/iptables/iptables.allow ];
then
sh /usr/local/virus/iptables/iptables.allow
fi
if [ -f /usr/local/virus/httpd-err/iptables.http ];
then
sh /usr/local/virus/httpd-err/iptables.http
fi
4. 允许某些类型的 ICMP 封包进入
AICMP="0 3 3/4 4 11 12 14 16 18"
for tyicmp in $AICMP
do
iptables -A INPUT -i $EXTIF -p icmp --icmp-type $tyicmp -j ACCEPT
done
# 5. 允许某些服务的进入，请依照你自己的环境开启
# iptables -A INPUT -p TCP -i $EXTIF --dport 21 --sport 1024:65534 -j ACCEPT # FTP
# iptables -A INPUT -p TCP -i $EXTIF --dport 22 --sport 1024:65534 -j ACCEPT # SSH
# iptables -A INPUT -p TCP -i $EXTIF --dport 25 --sport 1024:65534 -j ACCEPT # SMTP
# iptables -A INPUT -p UDP -i $EXTIF --dport 53 --sport 1024:65534 -j ACCEPT # DNS
# iptables -A INPUT -p TCP -i $EXTIF --dport 53 --sport 1024:65534 -j ACCEPT # DNS
# iptables -A INPUT -p TCP -i $EXTIF --dport 80 --sport 1024:65534 -j ACCEPT # WWW
# iptables -A INPUT -p TCP -i $EXTIF --dport 110 --sport 1024:65534 -j ACCEPT # POP3
# iptables -A INPUT -p TCP -i $EXTIF --dport 443 --sport 1024:65534 -j ACCEPT # HTTPS



# 第二部份，针对后端主机的防火墙设定！#
modules="ip_tables iptable_nat ip_nat_ftp ip_nat_irc ip_conntrack
ip_conntrack_ftp ip_conntrack_irc"
for mod in $modules
do
testmod=`lsmod | grep "^${mod} " | awk '{print $1}'`
if [ "$testmod" == "" ]; then
modprobe $mod
fi
done
# 清除 NAT table 的规则
iptables -F -t nat
iptables -X -t nat
iptables -Z -t nat
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT
# 成为路由器
if [ "$INIF" != "" ]; then
iptables -A INPUT -i $INIF -j ACCEPT
echo "1" > /proc/sys/net/ipv4/ip_forward
if [ "$INNET" != "" ]; then
for innet in $INNET
do
iptables -t nat -A POSTROUTING -s $innet -o $EXTIF -j
MASQUERADE
done
fi
fi

# 可能是 MTU 的问题，那你可以将底下这一行给他取消批注来启动 MTU 限制范围
# iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss
\
# --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu
# 4. NAT 服务器后端的 LAN 内对外之服务器设定
# iptables -t nat -A PREROUTING -p tcp -i $EXTIF --dport 80 \
# -j DNAT --to-destination 192.168.1.210:80 # WWW
# 5. 特殊的功能，包括 Windows 远程桌面所产生的规则，假设桌面主机为1.2.3.4
# iptables -t nat -A PREROUTING -p tcp -s 1.2.3.4 --dport 6000 \
# -j DNAT --to-destination 192.168.100.10
# iptables -t nat -A PREROUTING -p tcp -s 1.2.3.4 --sport 3389 \
# -j DNAT --to-destination 192.168.100.20
# 6. 最终将这些功能储存下来吧！
/etc/init.d/iptables save
iptables -A INPUT -i $EXTIF -s 140.116.44.0/24 -j ACCEPT
iptables -A INPUT -i $EXTIF -s 140.116.44.254 -j DROP







iptables -A INPUT -i  $INIF -j ACCEPT







web服务器常用的规则
###清理规则
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
#上面3条命令表示把全部的3条链路设置为开放，即所有访问都允许
iptables -F
iptables -X
#上面2条表示清空现有规则
#注意一定要依次运行上述5条规则，先设置3条链路开放再清空规则，如果直接清空规则会导致断开连接，这个时候直接硬重启机器即可恢复
###基础规则
#SSH
iptables -A INPUT -p tcp --dport 22  -j ACCEPT #ssh 端口22，默认端口22
iptables -A INPUT -p tcp --dport yiilib.com  -j ACCEPT #ssh 新端口 把如果新端口号为33333 则把yiilib.com换成33333即可
#因为ssh默认端口是22，而我们一般会修改端口，所以在切换的时候容易出问题，建议同时添加22和新端口2条命令，然后在切换完成后删除22 那条即可，具体删除方法见下文
#FTP
iptables -A INPUT -p tcp --dport 21 -j ACCEPT #ftp连接端口21
iptables -A INPUT -p tcp -m tcp --dport 50000:50100 -j ACCEPT  # ftp 被动端口 50000-51000
#在清理完规则后优先提示SSH和FTP规则是为了表示这2条规则的重要性，这是保命的规则，有这2条规则的前提下，你可以拥有ftp和ssh访问权限，就不会把自己关在门外了，话说玩iptables的人都应该有被关在门外的经历，说多了都是眼泪
#通用规则
iptables -A INPUT -p icmp --icmp-type any -j ACCEPT #允许icmp包进入
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT #允许已经建立和相关的数据包进入
iptables -A OUTPUT -p icmp --icmp any -j ACCEPT #允许icmp包出去
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT #允许已经建立和相关的数据包出去
#loopback and localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
#loopback是为127.0.0.1 这条规则这里主要是为了php-fpm访问127.0.0.1:9000端口这样的场景使用的
iptables -A INPUT -s localhost -d localhost -j ACCEPT #允许本地的数据包
iptables -A OUTPUT -s localhost -d localhost -j ACCEPT #允许本地数据包
#在一些案例中发现了localhost的写法，原则上使用loopback就足够了
###应用层面
#https
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT #打开https需要用到的443端口,用户以https方式访问时使用
#没有配置output 是因为上面有了“#允许已经建立和相关的数据包出去” 下面同理
#http
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT #打开http需要用到的80端口,用户以http方式访问时使用
#mysql
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT #主要用于mysql workbench远程数据管理，虽然知道不安全，但是有这么个坏习惯, 尽量使用比较复杂的用户名＋密码，屏蔽root，应该也还行
#ss
iptables -A INPUT -p tcp --dport 8989 -j ACCEPT #允许ss从8989建立连接，然后output同 #https
#这部分原理上可行，我还没有测试过，因为现在这个需求越来越多，所以在这里列出
###服务器上操作支持
#从服务器访问其他网站(包括wget下载一些数据包, yum做一些操作)，从服务器ping某一个域名，从服务器发送一封邮件等需要这些规则来做支持
#dns
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT #打开DNS需要用到的53端口
#https
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT #访问其他服务器的https
#没有配置input 是因为上面有了“#允许已经建立和相关的数据包进入” 下面同理
#http
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT #访问其他服务器的http
#ntpdate
iptables -A OUTPUT -p tcp --dport 123 -j ACCEPT #使用ntpdate更新时间
###防御型规则
#处理IP碎片数量,防止攻击,允许每秒100个
iptables -A FORWARD -f -m limit --limit 100/sec --limit-burst 100 -j ACCEPT 
#设置ICMP包过滤,允许每秒1个包,限制触发条件是10个包
iptables -A FORWARD -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT 
# ddos
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/min --limit-burst 100 -j ACCEPT 
###关闭所有不安全的端口
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j DROP
#在这里设置全部DROP就是说所有不在上面提到的数据包全部都直接丢弃不做任何处理，
至此所有需要的规则已经配置完成，除了我们上面允许的规则外，其他所有的访问都会被丢弃，这样就会安全许多，
也有人会把OUTPUT and FROWARD设置成 ACCEPT，这样也是可以的，那么上面对应的OUTPUT and FORWARD规则就可以不设置




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