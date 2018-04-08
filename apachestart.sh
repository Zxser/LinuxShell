#!/bin/bash
#Author: wangergui    Email:291131893@qq.com        Date:2016-06-01
#Function: source apache start script
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
APACHE=/usr/local/apache2/bin/apachectl
PIDFILE=/usr/local/apache2/logs/httpd.pid
[ -f /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions || exit 2
######################################  start   ########################
function mystart (){  
wget -q http://localhost >/dev/null 2>&1
if [ $? -eq 0 ] && [ -f ${PIDFILE} ];then
   echo -e "\033[40;32;1m httpd is already running!\033[0m"
 else
  rm -rf ${PIDFILE} && ${APACHE} 
   [ $? -eq 0 ] && echo -e "\033[40;32;1m httpd start sucessfully!\033[0m" || exit 4 
   [ $? -ne 0 ] && echo -e "\033[40;31;1m httpd start failed!\033[0m" || exit 5
fi
}
function mystop (){
curl -I -s http://localhost >/dev/null 2>&1
if [ $? -eq 0 ] && [ -f ${PIDFILE} ];then
   killproc httpd && echo -e "\033[40;31;1m httpd stop sucessfully!\033[40;0m"
 else
   echo -e "\033[40;31;1m httpd is not start!\033[0m"
fi

}
function myrestart (){
mystop
sleep 1
mystart
}
function myreload (){
wget -q http://localhost >/dev/null 2>&1
if [ $? -eq 0 ] && [ -f ${PIDFILE} ];then
    killproc httpd -HUP && echo "reload sucessfully!" || exit 6
else
   rm -rf ${PIDFILE} && echo -e "\033[40;31;1m httpd status is stop,reload failed\033[0m "

fi

}
function mystatus (){
wget -q http://localhost >/dev/null 2>&1
if [ $? -eq 0 ] && [ -f ${PIDFILE} ];then 
  echo -e "\033[40;32;1mhttpd is running!\033[0m"
 else 
  echo "httpd stop"
fi
}
case "$1" in
          "start")
                mystart
           ;;
          "stop")
          	 mystop
           ;;
          "restart")
          	 myrestart
           ;;
 
          "status")
          	 mystatus
           ;;
          "reload")
          	 myreload
           ;;

             *)
          echo $"Usage: $0 {start|stop|status|restart|reload|}"
	  exit 8
           ;;
esac
