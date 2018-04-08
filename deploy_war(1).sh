#!/bin/bash

direc=`dirname $0`

function check(){
	count=`ps -ef |grep tomcat |grep -v "grep" |wc -l`
	rmwar=`rm -rf /app/tomcat/webapps/*`
	cpportal=`cp /wartest/portal.war /app/tomcat/webapps/`
	starttomcat=`/app/tomcat/bin/startup.sh`
	shutdowntomcat=`ps -ef|grep tomcat |grep -v grep|cut -c 9-15|xargs kill -9`
if [ $count -eq 0 ];then
	$rmwar
	$cpportal
	[ $? -eq 0 ] && echo "copy portal.war success"|| echo "copy portal.war failure" && exit 1
	$starttomcat
	[ $? -eq 0 ] && echo "Tomcat direct start,This is a great script, and its author is Yang Bo" || echo "Tomcat direct start is failure" && exit 1
	else
	$shutdowntomcat
	[ $? -eq 0 ] && echo "tomcat shutdown success"|| echo "tomcat shutdown failure" && exit 1
	$rmwar
	$cpportal
	[ $? -eq 0 ] && echo "copy portal.war success"|| echo "copy portal.war failure" && exit 1
	$starttomcat
        [ $? -eq 0 ] && echo "Tomcat is the first to turn off after the start,This is a great script, and its author is Yang Bo" || echo "Tomcat is the first to turn off after the start of the failure" && exit 1		
fi
}
check
