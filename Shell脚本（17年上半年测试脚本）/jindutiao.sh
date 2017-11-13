#!/bin/bash
for mqy in `seq -w 500`
do
 useradd abc-$mqy  
 echo "123456" | passwd abc-$mqy --stdin &>/dev/null

while [ $mqy -lt 501  ]
do
	((mqy++))
	echo -ne ">=\033[s"
 	echo -ne "\033[40;50H]"$((i*5*100/100))%"\033[u\033[1D]"
	usleep  50000
	done 
	done
echo
