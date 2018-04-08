#!/bin/bash
#Author: wangergui        Email:291131893@qq.com       Date:2016-05-31
#Function: print a triangle
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
read -p "input a integral number : " NUM
TOTALLINE=$((`stty -F /dev/console size | awk '{print $2}'`/2))
echo ${TOTALLINE}
for i in `seq 1 ${NUM}`;do
        STAR=$(( ($i-1) * 2 +1))
        SPACESLINE=$(( ${TOTALLINE} - $i ))
        for j in `seq 1 ${SPACESLINE}`;do
        echo -n " "
        done
        for k in `seq 1 ${STAR}`;do
        echo -n "*"
        done
        echo
done
