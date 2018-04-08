#!/bin/bash

function qiu1()
{
     qiu=()
     for ((s=1;s<=32;s++))
     do
		[ $s -lt "10" ]&&qiu[$s]=0$s||qiu[$s]=$s
     done	
}
qiu1

function lanqiu()
{
     qiu2=()
     for ((s=1;s<=32;s++))
     do
          [ $s -lt "10" ]&&qiu2[$s]=0$s||qiu2[$s]=$s
     done
}
lanqiu

function hong()
{
	for ((n=1;n<=6;n++))
	do
	     haoma=$(($RANDOM%32+1))
	     echo -n "${qiu[$haoma]} "
	     unset qiu[$haoma]
	done
}
function lan()
{
	qwe=$(($RANDOM%32+1))
	lll=${qiu2[$qwe]}
	echo -n -e "\033[34m $lll \033[1m"
	echo -e "\033[0m"
}

function zzz ()
{
	a=`hong`
	k=`echo $a | awk '{print $6}'`
	while [[ -z $k ]]
	do
		a=`hong`
		k=`echo $a | awk '{print $6}'`
	done
	echo -n -e "\033[31m $a\033[1m"
	echo -n -e "\033[0m"
	lan
}

if [[ -z $1 ]]
then
	echo "$0 : {number}"
	exit
fi

for ((f=1;f<=$1;f++))
do
	zzz
done
