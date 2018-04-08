#!/bin/bash
if [ -z $1 ]
then
	echo "USAGE $(basename $0) word "
	exit 10
else
WORD=$1
fi
CMD=$(curl -s http://dict.cn/$WORD |sed -n '/basic clearfix/,/padding-top/p'| grep -Po '(?<=<span>).*(?=</span>)|(?<=<strong>).*(?=</strong>)')
if [ $? -eq 0 ]
then
echo $CMD
else
echo 'error'
fi

