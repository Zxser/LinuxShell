#!/bin/bash
# chkconfig: - 18 21
# description: http service.
# Source Function Library
. /etc/init.d/functions
# Nginx Settings
NGINX_SBIN="/usr/sbin/nginx"
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_PID="/var/run/nginx.pid"
RETVAL=0
prog="Nginx"
#Source networking configuration
. /etc/sysconfig/network
# Check networking is up
[ ${NETWORKING} = "no" ] && exit 0
[ -x $NGINX_SBIN ] || exit 0
start() {
        echo -n $"Starting $prog: "
        touch /var/lock/subsys/nginx
        daemon $NGINX_SBIN -c $NGINX_CONF
        RETVAL=$?
        echo
        return $RETVAL
}
stop() {
        echo -n $"Stopping $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -TERM
        rm -rf /var/lock/subsys/nginx /var/run/nginx.pid
        RETVAL=$?
        echo
        return $RETVAL
}
reload(){
        echo -n $"Reloading $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -HUP
        RETVAL=$?
        echo
        return $RETVAL
}
restart(){
        stop
        start
}
configtest(){
    $NGINX_SBIN -c $NGINX_CONF -t
    return 0
}
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  reload)
        reload
        ;;
  restart)
        restart
        ;;
  configtest)
        configtest
        ;;
  *)
        echo $"Usage: $0 {start|stop|reload|restart|configtest}"
        RETVAL=1
esac
exit $RETVAL
