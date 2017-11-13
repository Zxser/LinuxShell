for i in $(seq -w 500)
    do  
        useradd abc-$i && 
        echo "123456" | passwd abc-$i --stdin &> /dev/null
done


for i in $(seq -w 500)
do userdel  -r abc-$i
done



#!/bin/sh 
i=0
while [ $i -lt 20 ] 
do
      ((i++))
      echo -ne  "=>\033[s"
      echo -ne  "\033[40;50H"$((i*5*100/100))%"\033[u\033[1D"
      usleep 50000
      done
echo





#!/bin/bash
i=0
while [ $i -lt 10]
do
    for i in   '-' '\\'  '|' '/' 
    do
        echo -ne    "\033[1D$j"
        usleep 50000
        done 
        ((i++))
done