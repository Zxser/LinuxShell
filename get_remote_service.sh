#!/bin/bash
for ip in `cat remote_host_ip`
do
echo "$ip" >>/tmp/get_remote_host_info.log
sshpass -p P@ss2010 ssh centos@$ip -o StrictHostKeyChecking=no hostname >>/tmp/get_remote_host_info.log
sshpass -p P@ss2010 ssh centos@$ip -o StrictHostKeyChecking=no sudo su - root <<"EOF" >>/tmp/get_remote_host_info.log
netstat -tanpl |grep  '^tcp'|grep -Ev '::ffff|sshd|master|-'|awk -F '[: /]+' '{print $5,$(NF-1)}'|awk '!a[$2]++'|column -t
EOF
wait
sshpass -p P@ss2010 ssh centos@$ip -o StrictHostKeyChecking=no sudo su - root <<"EOF" >>/tmp/get_remote_host_info.log
awk 'NR==FNR{match($4,/:([0-9]+)$/,a);match($7,"([^/]+)/",b);c[b[1]]=a[1];next}!d[$2]++{printf (!f++?"":RS) $2}{printf FS c[$1]}END{print""}'  <(netstat -tanpl |grep  '^tcp'|grep -Ev '::ffff|sshd|master|-')  <(ps -ef | grep [j]ava |awk -F/ '!a[$NF]++'|grep -v '|'|awk -F '[ ]+' '{print $2,$NF}')
EOF
echo "==============================================" >>/tmp/get_remote_host_info.log
done
