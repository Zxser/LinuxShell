#多网卡同网段多IP网络分流设定方法
#根据自己需求修改
#!/bin/bash
# 添加多路由分流
GATEWAY=192.168.1.1
ETH0=`/sbin/ifconfig eth0|grep "inet addr"|head -n 2|/bin/awk '/inet addr/ {split($2,x,":");print x[2]}'|head -1`
ETH1=`/sbin/ifconfig eth1|grep "inet addr"|head -n 2|/bin/awk '/inet addr/ {split($2,x,":");print x[2]}'|head -1`
route add -net 0.0.0.0 netmask 0.0.0.0 gw $GATEWAY dev eth0
route add -net 0.0.0.0 netmask 0.0.0.0 gw $GATEWAY dev eth1
ip route add to 0.0.0.0/0 via $GATEWAY dev eth0 table 10
ip route add to 0.0.0.0/0 via $GATEWAY dev eth1 table 20
ip rule add from $ETH0/32 table 10
ip rule add from $ETH1/32 table 20
route -n
