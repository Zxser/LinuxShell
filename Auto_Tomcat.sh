#!/bin/bash
#FileName Auth_Tomcat.sh
#Date 2016-08-16
#Author fsx
#__________________________________________________________________________

#检查是否已经安装Tomcat、如已安装列出相应安装目录及运行端口号
#Tomcat进程pid
#TomcatRunCount=`ps -elf|grep tomcat|grep -v grep|wc -l`
TomcatRunCount=`ps -aux|grep tomcat|grep -v grep|cut -b 10-15|wc -l`
#PID=`ps -aux|grep tomcat|grep -v grep|cut -d" " -f6-7`
PID=`ps -aux|grep tomcat|grep -v grep|cut -b 10-15`
echo "$PID"
echo -e "\033[33m服务器运行的Tomcat个数为:\n$TomcatRunCount\033[0m"

for pid in $PID;
do
    if [ -n $pid ];then
    	#根据pid获取相关Tomcat的启动端口号
    	TomcatRunPort=`netstat -lnpt|grep $pid|cut -d":" -f2|cut -d" " -f1`
    	echo -e "\033[33mTomcat运行端口号:\n$TomcatRunPort\033[0m"
    	#获取tomcat进程
    	TomcatProcess=`ps -elf|grep tomcat|grep -v grep|grep $pid`
   	#根据进程获取到tomcat的安装目录
    	TomcatDir=`echo ${TomcatProcess##*home=}`
    	echo -e "\033[33mTomcat安装目录为:\n${TomcatDir%% *}\033[0m"
	echo "---------------------------------------------"
    else
	echo -e "\033[33mTomcat没有安装或者启动\033[0m"
    fi
done;


#Tomcat安装目录名称,根据变量传入
TomcatPath=/usr/local/$1
TomcatName=$1
#定义Tomcat自启动脚本功能、启动、停止、重启及注册到系统服务器中，使用service xxx start方式
tomcatStart(){
(
cat << EOF
#!/bin/bash
#FileName TomcatServer
#chkconfig: - 86 14
#description: Auto Script Service
#processname: APP_NAME=$TomcatName
psid=0
TomcatServerName="$TomcatName"
checkpid(){
    tomcatPid=\`ps -elf|grep \$TomcatServerName|grep -v grep\`
    if [ -n \$tomcatPid ];then
        psid=\`echo \$tomcatPid|awk '{print \$4}'\`
    else
        psid=0
    fi
}
dev="/dev/null"
startup_bin="$TomcatPath/bin/startup.sh"
shutdown_bin="$TomcatPath/bin/shutdown.sh"
#Tomcat Start Function
start(){
    checkpid
    if [ \$psid -ne 0 ];then
        echo -e "\033[33m\$TomcatServerName already started!(pid=\$psid)\033[0m"
    else
        echo -e "\033[33mStarting \$TomcatServerName....\033[0m"
        \$startup_bin &>\$dev
        echo -e "\033[33m\$TomcatServerName starting,Please wait 3s…\033[0m"
        sleep 3s
        checkpid
        if [ \$psid -ne 0 ];then
            echo -e "\033[33m(pid=\$psid)[OK]\033[0m"
        else
            echo -e "\033[33m[StartUp Failed]\033[0m"
        fi
    fi
}
#Stop Tomcat Function
stop(){
    checkpid
    if [ \$psid -ne 0 ];then
        echo -e "\033[33mStopping \$TomcatServerName...(pid=\$psid)\033[0m"
        \$shutdown_bin &>\$dev
        echo -e "\033[33m\$TomcatServerName is Stopping,Please Wait 3s...\033[0m"
        sleep 3s
        if [ \$? -eq 0 ];then
            echo -e "\033[33m[OK]\033[0m"
        else
            echo -e "\033[33m[Failed]\033[0m"
        fi
        checkpid
        if [ \$psid -ne 0 ];then
            stop
        fi
    else
        echo -e "\033[33mwarn: \$TomcatServerName Is Not Running\033[0m"
    fi
}
#Check Tomcat Run Status
status(){
    checkpid
    if [ \$psid -ne 0 ];then
        echo -e "\033[33m\$TomcatServerName Is Running!(pid=\$psid)\033[0m"
    else
        echo -e "\033[33m\$TomcatServerName Is Not Running\033[0m"
    fi
}
###
case "\$1" in
        'start')
             start
             ;;
        'stop')
             stop
             ;;
        'restart')
             stop
             start
             ;;
        'status')
             status
             ;;
        *)
             echo -e "\033[33mUsage: \$0 {start|stop|restart|status}\033[0m"
             exit 1
esac
exit 0
EOF
)>/etc/init.d/$TomcatName
cd /etc/init.d/
#赋予脚本执行权限
chmod a+x $TomcatName
#加入到系统服务中
chkconfig --add $TomcatName
#设置运行级别模式,使服务器开机自启动
chkconfig --level 235 $TomcatName on
}

#安装Tomcat
if [ ! -d "$TomcatPath" ]; then
	#下载Tomcat安装包，并解压缩
	cd /opt/
	wget http://1.1.1.1/TOMCAT/apache-tomcat-8.0.26.tar.gz
	#解压缩
	tar zxf apache-tomcat-8.0.26.tar.gz
	#判断解压缩是否完成
	if [ $? -eq 0 ];then
        echo -e "\033[33mTomcat源码包解压缩完毕!\033[0m"
		#删除源码安装包
		rm -rf apache-tomcat-8.0.26.tar.gz
		#move到标准安装路径中
		mv apache-tomcat-8.0.26 $TomcatPath
		#删除examples、doc等文件夹，防止安全漏洞
		rm -rf $TomcatPath/webapps/docs  
		rm -rf $TomcatPath/webapps/examples
		#根据传入的参数，修改Tomcat监听、Apache、停止端口号
		sed -i "s#8080#$2#g" $TomcatPath/conf/server.xml
		sed -i "s#8005#$3#g" $TomcatPath/conf/server.xml
		sed -i "s#8009#$4#g" $TomcatPath/conf/server.xml
		#调用tomcatStart()方法,生成服务自启动脚本
		tomcatStart
		echo -e "\033[33mTomcat安装配置完毕,请使用service $TomcatName start|stop|restart\033[0m"
	else
            echo -e "\033[33m文件解压缩失败\033[0m"
	fi
else
	echo -e "\033[33m$TomcatPath 文件夹已经存在\033[0m"
	echo -e "\033[33m请传入位置参数:\n参数1.Tomcat安装目录名称,例如:tomcat-8.0-8080\n参数2.Tomcat监听端口,默认为8080\n参数3.Tomcat关闭端口,默认为8005\n参数4.Tomcat的apache监听端口,默认为8009\033[0m"
fi

