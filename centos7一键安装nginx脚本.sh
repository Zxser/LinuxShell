#centos7一键安装nginx脚本
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/opt/bin:/opt/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install"
    exit 1
fi

# Check the network status
NET_NUM=`ping -c 4 www.baidu.com |awk '/packet loss/{print $6}' |sed -e 's/%//'`
if [ -z "$NET_NUM" ] || [ $NET_NUM -ne 0 ];then
    echo "Please check your internet"
    exit 1
fi

# Check the OS
if [ "$(awk '{if ( $3 >= 7.0 ) print "CentOS 7.x"}' /etc/redhat-release 2>/dev/null)" != "CentOS 7.x" ];then
    err_echo "This script is used for RHEL/CentOS 7.x only."
    exit 1
fi

function InitInstall()
{
	#Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	yum install -y ntpdate
	ntpdate -u pool.ntp.org
	date -R

	rpm -qa|grep httpd
	rpm -e httpd
	yum -y remove httpd
	yum -y install yum-fastestmirror
	yum -y install gcc gcc-c++ make pcre-devel GeoIP* openssl-devel perl-devel perl-ExtUtils-Embed

	if [ -s /data/www/vhosts ];then
		echo "The web directory already exists!"
	else
		mkdir -p /data/www/vhosts
	fi	
}

function CheckAndDownloadFiles()
{
echo "============================check files=================================="
if [ -s nginx-1.10.2.tar.gz ];then
	echo "nginx-1.10.2.tar.gz [found]"
else
	wget -c http://download.slogra.com/nginx/nginx-1.10.2.tar.gz
fi
echo "============================check files=================================="
}

function InstallNginx()
{
echo "============================Install Nginx 1.10.2=================================="
user_nginx=`cat /etc/passwd|grep nginx|awk -F : '{print $1}'`
if [ -z "$user_nginx" ];then
	groupadd nginx
	useradd -s /sbin/nologin -M -g nginx nginx
else
	echo "user nginx already exists!"
fi

tar zxf nginx-1.10.2.tar.gz && cd nginx-1.10.2
export CFLAGS="-Werror"
./configure --user=nginx --group=nginx  --prefix=/usr/share/nginx \
--sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
--http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
--http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx \
--with-http_secure_link_module --with-http_random_index_module --with-http_ssl_module --with-http_realip_module \
--with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module \
--with-http_gzip_static_module --with-http_stub_status_module --with-http_perl_module \
--with-http_geoip_module --with-mail --with-mail_ssl_module \
--with-cc-opt='-O3' --with-cpu-opt=pentium

make && make install

cat >/lib/systemd/system/nginx.service<<EOF
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/nginx/nginx.conf<<EOF
user nginx nginx;
worker_processes  8;
worker_rlimit_nofile 65535;

error_log   /var/log/nginx/error.log;

pid        /var/run/nginx.pid;


events {
    use epoll;
    worker_connections  65535;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent $request_time "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for" "$request_time"';

    access_log  /var/log/nginx/access.log  main;

    server_names_hash_bucket_size 128;
    client_header_buffer_size 16k;
    large_client_header_buffers 4 32k;
    client_body_in_file_only clean;
    client_max_body_size 20m;

    #open_file_cache max=10240 inactive=20s;
    #open_file_cache_valid 30s;
    #open_file_cache_min_uses 1;

    sendfile        on;
    tcp_nopush      on;

    keepalive_timeout  60;
    tcp_nodelay on;
    server_tokens   off;

    fastcgi_connect_timeout 300s;
    fastcgi_send_timeout 300s;
    fastcgi_read_timeout 300s;
    fastcgi_buffer_size 128k;
    fastcgi_buffers 8 128k;#8 128
    fastcgi_busy_buffers_size 256k;
    fastcgi_temp_file_write_size 256k;
    fastcgi_intercept_errors on;

    #hiden php version
    fastcgi_hide_header X-Powered-By;

    gzip on;
    gzip_min_length 1k;
    gzip_buffers 16 64k;
    gzip_http_version 1.0;
    #gzip_disable "MSIE [1-5]\.";
    gzip_comp_level 4;
    gzip_types text/plain application/x-javascript text/css application/xml image/gif image/jpg image/jpeg image/png;
    gzip_vary on;
    #proxy_hide_header Vary;

    #limit_zone conlimit $binary_remote_addr  1m;
    #limit_conn conlimit 5;

    server {
	listen	80 default;
        server_name  _;
        return 500;
	}

        include /etc/nginx/conf.d/*.conf;
    }
EOF

systemctl enable nginx
systemctl start nginx
echo "============================Nginx 1.10.2 install completed========================="
}

function CheckInstall()
{
echo "===================================== Check install ==================================="
clear
isnginx=""
echo "Checking..."
if [ -s /usr/local/nginx ] && [ -s /etc/nginx/nginx.conf ];then
	  echo "Nginx: OK"
	  isnginx="ok"
else
	  echo "Error: /usr/local/nginx not found!!!Nginx install failed."
fi

if [ "$isnginx" = "ok" ];then
	echo "Install Nginx 1.10.2 completed! enjoy it."
	echo "========================================================================="
	netstat -ntl
else
	echo "Sorry,Failed to install nginx!"
	echo "You can tail /root/nginx-install.log from your server."
fi
}

#The installation log
InitInstall 2>&1 | tee /root/nginx-install.log
CheckAndDownloadFiles 2>&1 | tee -a /root/nginx-install.log
InstallNginx 2>&1 | tee -a /root/nginx-install.log
CheckInstall 2>&1 | tee -a /root/nginx-install.log