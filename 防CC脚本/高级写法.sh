#防cc脚本
#!/bin/bash
#Desc:Auto Deny Black_IP Script.
#Date:2018/2/21
#取得参数$1为并发阈值，若留空则默认允许单IP最大50并发(实际测试发现，2M带宽，十来个并发服务器就已经无法访问了！)
#将以上代码保存为 deny_blackip.sh 之后，进入到脚本文件所在目录，然后使用如下命令后台执行脚本（后面的 50 表示并发数，可自行调整）：nohup ./deny_blackip.sh 50 &
#执行后会出现如下信息：
#Shell
#[root@Mars_Server iptables]# nohup ./deny_blackip.sh 50 & 
#[1] 23630
#[root@Mars_Server iptables]# nohup: ignoring input and appending output to `nohup.out'
#[root@Mars_Server iptables]# nohup ./deny_blackip.sh 50 & 
#[1] 23630
#[root@Mars_Server iptables]# nohup: ignoring input and appending output to `nohup.out'
#表示如果脚本产生输出信息，将会写入到 nohup.out 文件，可以看到当前目录已经生成了一个空的 nohup.out：
#Shell
#[root@Mars_Server iptables]# ll nohup.out
#-rw------- 1 root root 0 Nov  5 21:15 nohup.out
#[root@Mars_Server iptables]# ll nohup.out
#-rw------- 1 root root 0 Nov  5 21:15 nohup.out
#好了，现在你执行执行 ps aux 应该可以找到如下进程：
#Shell
#root     23630  0.0  0.2   5060  1224 pts/0    S    21:15   0:00 /bin/bash ./deny_blackip.sh
#root     23964  0.0  0.0   4064   508 pts/0    S    21:19   0:00 sleep 10

#root     23630  0.0  0.2   5060  1224 pts/0    S    21:15   0:00 /bin/bash ./deny_blackip.sh
#root     23964  0.0  0.0   4064   508 pts/0    S    21:19   0:00 sleep 10
#一切顺利！每 10s 将检查一次服务器请求，如果某个 IP 超过 50 个并发，立即拉黑，并发一封邮件给你！

if [[ -z $1 ]];then
        num=50
else 
        num=$1
fi

#巧妙的进入到脚本工作目录
cd $(cd $(dirname $BASH_SOURCE) && pwd)

#请求检查、判断及拉黑主功能函数
function check(){
        iplist=`netstat -an |grep ^tcp.*:80|egrep -v 'LISTEN|127.0.0.1'|awk -F"[ ]+|[:]" '{print $6}'|sort|uniq -c|sort -rn|awk -v str=$num '{if ($1>str){print $2}}'`
        if [[ ! -z $iplist ]];
                then
                >./black_ip.txt
                for black_ip in $iplist
                do
                        #白名单过滤中已取消IP段的判断功能，可根据需要自行修改以下代码(请参考前天写的脚本)
                        #exclude_ip=`echo $black_ip | awk -F"." '{print $1"."$2"."$3}'`
                        #grep -q $exclude_ip ./white_ip.txt
                        grep -q $black_ip ./white_ip.txt
                        if [[ $? -eq 0 ]];then
                                echo "$black_ip (white_ip)" >>./black_ip.txt
                        else
                                echo $black_ip >>./black_ip.txt     
                                iptables -nL | grep $black_ip ||(iptables -I INPUT -s $black_ip -j DROP & echo "$black_ip  `date +%Y-%m-%H:%M:%S`">>./deny.log & echo 1 >./sendmail)
                        fi
                done
                #存在并发超过阈值的单IP就发送邮件
                if [[ `cat ./sendmail` == 1 ]];then sendmsg;fi
        fi
}

#发邮件函数
function sendmsg(){
        netstat -nutlp | grep "sendmail" >/dev/null 2>&1 || /etc/init.d/sendmail start >/dev/null 2>&1
        echo -e "From: 发邮件地址@qq.com\nTo:收邮件地址@qq.com\nSubject:Someone Attacking your system!!\nIts Ip is" >./message
        cat ./black_ip.txt >>./message
        /usr/sbin/sendmail -f 发邮件地址@qq.com -t 收邮件地址@qq.com -i <./message
        >./sendmail
}

#间隔10s无限循环检查函数
while true
do 
        check
        #每隔10s检查一次，时间可根据需要自定义
        sleep 10
done
