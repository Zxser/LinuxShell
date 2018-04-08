#!/bin/bash
##!/usr/bin/expect
D=`date +%Y_%m_%d_bak`
for i in $(awk '{print $2}' allip)
do
  for j in $(awk '{print $3}' allip)
  do
expect <<!
     spawn ssh root@$i
     expect "*password:"
     send "Abcd1234\r"
     expect "*~>"
     #### 已经登录
     #### 登录进入后，执行命令：
     send "cd /opt/IBM/pdps/apache-tomcat-6.0.14_x64/webapps/pdps\r"
     expect "*~>"
     send "cp  Config Config_$D\r"
     expect "*~>"
     send "echo $j > Config\r"
     expect "*~>"
     send "cat Config\r"
     expect "*~>"
     send "exit\r"
     expect eof
!
  done
done
