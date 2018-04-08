#!/bin/bash
#Author:wangergui	Email:291131893@qq.com		Date:2016-09-17
#Release 1.0
#Function:shuang se qiu
declare -a RED

read -t 10 -p "Please input a number: " NUM
STR=`echo ${NUM} |sed 'sN^.*[[:digit:]]$NNg'`
[[ -z "${STR}" ]] || exit 2

for I in `seq ${NUM}`;do

       while true;do

RED=($(($RANDOM % 33 +1)) $(($RANDOM % 33 +1)) $(($RANDOM % 33 +1)) $(($RANDOM % 33 +1)) $(($RANDOM % 33 +1)) $(($RANDOM % 33 +1)))
BLUE=$(($RANDOM % 16 +1))
STRING=`(for J in "${RED[@]}";do echo $J;done) |sort |uniq -d`

	if  [[ -z "${STRING}" ]];then
	
	echo -e "\E[40;31;1m ${RED[@]}\E[0m || \E[40;34;1m ${BLUE}\E[0m"  && break 

	fi

	done
done



