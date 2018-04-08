#!/usr/bin/bash
source /seccheck/linux_seccheck.sh
time=`date "+%Y-%m-%d %H:%M:%S"`
hostname=`hostname`
echo -e "*********** ${time} 主机(${hostname})安全检查 ***********\n"
echo "下面开始进行(CPU)检查："
cpu
echo "下面开始进行(内存)检查："
memory
echo "下面开始进行(磁盘)检查："
disk
echo "下面开始进行(网卡实时流量)检查："
nic
echo "下面开始进行(IPV6)检查："
ipv6
echo "下面开始进行(网卡运行模式)检查："
nic_mode
echo "下面开始进行(Telnet)检查："
telnet
echo "下面开始进行(Grub密码)检查："
grub
echo "下面开始进行(SSH)检查："
ssh
echo "下面开始进行(类ROOT特权用户)检查："
root_user
echo "下面开始进行(空密码)检查："
nopasswd
echo "下面开始进行(密码策略)检查："
passwd_check
echo "下面开始进行(文件权限)检查："
file_auth
echo "下面开始进行(文件ai属性)检查："
file_ai
echo "下面开始进行(文件锁定)检查："
file_lock
echo "下面开始进行(僵尸进程)检查："
zombie_process
echo "下面开始进行(连接数)检查："
link_num
echo "下面开始进行(日志审计)检查："
log_audit
echo "下面开始进行(用户行为审计)检查："
user_monitor_check
echo "下面开始进行(病毒、木马和病毒)检查："
back_door

