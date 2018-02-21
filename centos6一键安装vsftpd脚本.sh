#centos6一键安装vsftpd脚本
#添加ftp用户 （命令执行：sh xxx.sh add）
#卸载vsftpd （命令执行：sh xxx.sh uninstall）
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