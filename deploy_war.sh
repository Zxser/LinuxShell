#!/bin/bash

direc=`dirname $0`

function check(){
	count=`ps -ef |grep tomcat |grep -v "grep" |wc -l`
	rmwar=`rm -rf /app/tomcat/webapps/*`
	cpdata=`cp /wartest/data.war /app/tomcat/webapps/`
	starttomcat=/app/tomcat/bin/startup.sh
	shutdowntomcat=`ps -ef|grep tomcat |grep -v grep|cut -c 9-15|xargs kill -9`
	warfile=/wartest/data.war
	rm_wartest=`rm -rf /wartest/bak/data_*.war`
	bak_war=`mv /wartest/data.war /wartest/bak/data_\`date +%Y%m%d_%H%M%S\`.war`
if [ $count -eq 0 ];then
	[ -e $warfile ] && $rmwar|| exit 1	
	$cpdata
	[ $? -eq 0 ] && echo "copy data.war success"|| exit 1
	$starttomcat
	$rm_wartest
	$bak_war
#	[ $? -eq 0 ] && echo "Tomcat direct start,This is a great script, and its author is Yang Bo" || exit 1
	else
	[ -e $warfile ] && echo "war is exist"|| exit 1
	$shutdowntomcat
	[ $? -eq 0 ] && echo "tomcat shutdown success"|| exit 1
	$rmwar
	$cpdata
#	[ $? -eq 0 ] && echo "copy data.war success"|| exit 1
	$starttomcat
	$rm_wartest
        $bak_war
        #[ $? -eq 0 ] && echo "Tomcat is the first to turn off after the start,This is a great script, and its author is Yang Bo" || exit 1		
fi
}
check

