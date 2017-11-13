#!bin/bash
ping -c 3 -i 0.2 -W 3 $1 &> /dev/null    
#-c 是发送三个包  -r 发送包的间隔 -w  等待时间
if [ $? -eq 0 ]
then
echo "Host $1 is up"
else
echo "Host $1 is down"
fi