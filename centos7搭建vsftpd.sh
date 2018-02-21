#centos7一键安装vsftpd脚本
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/opt/bin:/opt/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install"
    exit 1
fi

# Check the OS
if [ "$(awk '{if ( $3 >= 7.0 ) print "CentOS 7.x"}' /etc/redhat-release 2>/dev/null)" != "CentOS 7.x" ];then
    err_echo "This script is used for RHEL/CentOS 7.x only."
    exit 1
fi

platform=`uname -i` 
if [ $platform = "x86_64" ];then
echo "  the platform is ok"
else
echo "this script is only for 64bit Operating System !"
exit 1
fi


vuser=`cat /etc/passwd|grep vuser|awk -F : '{print $1}'`
if [ -z "$vuser" ];then
ftpuser=`useradd vuser -s /sbin/nologin`
read -p "please enter the vuser password:" pwd
	echo '$pwd'|passwd --stdin $ftpuser
else
	echo "user vuser already exists!"
fi

read -p "Enter the ftp directory:" ftplist
read -p "Enter the ftp virtual user": user
read -p "Enter the ftp virtual user password:" passwd

if [ -s /usr/sbin/vsftpd ];then
	echo "Installed!"
else	
	yum -y install db4 db4-devel db4-java db4-utils db4-tcl vsftpd
fi

cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.$(date +%Y%m%d)bak--
cat >/etc/vsftpd/vsftpd.conf<<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=YES
pam_service_name=ftp.vu
userlist_enable=YES
tcp_wrappers=YES
use_localtime=YES
guest_enable=YES
guest_username=vuser
user_config_dir=/etc/vsftpd/user_conf
seccomp_sandbox=NO
allow_writeable_chroot=YES
EOF

cat >/etc/vsftpd/vuser<<EOF
$user
$passwd
EOF

chmod 600 /etc/vsftpd/vuser
cd /etc/vsftpd/
db_load -T -t hash -f vuser vuser.db
chmod 600 /etc/vsftpd/vuser.db

cp /etc/pam.d/vsftpd /etc/pam.d/ftp.vu
cat >/etc/pam.d/ftp.vu<<EOF
auth    required   /lib64/security/pam_userdb.so   db=/etc/vsftpd/vuser
account required   /lib64/security/pam_userdb.so   db=/etc/vsftpd/vuser
EOF

mkdir /etc/vsftpd/user_conf
cat >/etc/vsftpd/user_conf/$user<<EOF
local_root=$ftplist
anon_world_readable_only=NO
write_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
anon_umask=022
EOF

/usr/sbin/iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
sed -i '6 s/IPTABLES_MODULES=""/IPTABLES_MODULES="ip_conntrack_ftp"/g' /etc/sysconfig/iptables-config

echo "vsftpd installation is complete,Assign permissions to the ftp directory."
#####给ftp上一级目录赋权限.
read -p "Ftp directory on a directory:" ftpadd
chown -R $ftpuser.$ftpuser $ftpadd

systemctl start vsftpd

echo "OK! Install complete!"