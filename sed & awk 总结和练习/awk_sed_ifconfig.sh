#!/bin/bash

#ifconfig | sed -r '/(Bcast)|(HWaddr)/!d;s/(.*)Link(.*)/\1/g;s/(.*):(.*)(Bcast)(.*)/\2/g'
#ifconfig | awk -F 'Link(.*)|Bcast|inet addr:' '/(Bcast)|(HWaddr)/{print $1,$2}'

s=`ifconfig | sed -r '/(Bcast)|(HWaddr)/!d;s/(.*)Link(.*)/\1/g;s/(.*):(.*)(Bcast)(.*)/\2/g'`
a=`ifconfig | awk -F 'Link(.*)|Bcast|inet addr:' '/(Bcast)|(HWaddr)/{print $1,$2}'`

#没有双引号输出 这样不会输出变量内的空格换行等 会在一行输出 
echo "没有双引号输出 这样不会输出变量内的空格换行等 会在一行输出"
echo $a
echo $s
echo "###############"
#有双引号输出 这样会按照变量内原有的字符输出包括空格以及换行等
echo "有双引号输出 这样会按照变量内原有的字符输出包括空格以及换行等"
echo "$a"
echo "$s"
echo "###############"

#把变量a保存到数组 目的是为了输出的更好看
a=($a)
#直接输出 与不加双引号输出的格式是一样的
echo "把变量a放进数组 目的是为了调整输出格式 "
echo "这里是直接输出的数组"
echo ${a[@]}
#用循环输出数组内的元素
echo "这里用for循环输出 每次输出两个数组元素 然后换行"
for ((i=0;i<${#a[@]};i+=2))
do
	echo -e "${a[$i]}\t${a[$(($i+1))]}"
done

echo "##################################"
#带子网掩码
#ifconfig | sed -r '/(HWaddr)|(Bcast)/!d;s/(.*)Link(.*)/\1/g;s/(.*):(.*)B(.*)Mask:(.*)/\2 \4/g'
#ifconfig | awk -F 'Link(.*)|inet addr:|Bcast|Mask:' '/(HWaddr)|(Bcast)/{print $1,$2,$NF}'

s=`ifconfig | sed -r '/(HWaddr)|(Bcast)/!d;s/(.*)Link(.*)/\1/g;s/(.*):(.*)B(.*)Mask:(.*)/\2 \4/g'`
a=`ifconfig | awk -F 'Link(.*)|inet addr:|Bcast|Mask:' '/(HWaddr)|(Bcast)/{print $1,$2,$NF}'`

#这里同上
echo "这里是带子网掩码的部分"
a=($a)
echo ${a[@]}
for ((i=0;i<=${#a[@]};i+=3))
do
	echo -e "${a[$i]}\t${a[$(($i+1))]} ${a[$(($i+2))]}"
done
