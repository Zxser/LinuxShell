# processbar <current> <total>  
processbar() {  
  local current=$1; local total=$2;  
  local maxlen=80; local barlen=66; local perclen=14;  
  local format="%-${barlen}s%$((maxlen-barlen))s"  
  local perc="[$current/$total]"  
  local progress=$((current*barlen/total))  
  local prog=$(for i in `seq 0 $progress`; do printf '#'; done)  
  printf "\r$format" $prog $perc  
}  
  
# Usage(Client)  
for i in `seq 1 10`; do  
  processbar $i 10  
  sleep 1  
done  
echo ""  




#!/bin/sh

x=''
e=`seq -w 500`
for a in $e
            do useradd test-$a
            echo 1 | passwd --stdin test-$a &> /dev/null
            cat /etc/passwd | awk -F : '{print $1}'
            o=$[`echo $e | awk  '{print NF}' `/5]
for ((i=0;$i<=100;i+=2))
do
    printf "test:[%-50s]%d%%\r" $x $i
    sleep 0.1
    
    x=#$x
done
echo