#批量生成ip地址
#!/bin/bash
a=$1
b=$2 for ((c=$ 3;c<255;c++))
do for ((d=$ 4;d<255;d++ ))
do echo $a.$b.$c.$d>>ip.txt
done done	



for((i=0;i<100;i++))

do 

     sleep 0.1 

     echo $i | dialog --title 'Copy' --gauge 'I am busy!' 10 70 0 

done



今天做一个wget的下载脚本看不见执行情况，于是想写一个进度条表示的直观一些。

想到了以前看软件安装时候的######进度条，这个比较容易：

#!/bin/sh



x=''

for ((i=0;$i<=100;i+=2))
do
    printf "test:[%-50s]%d%%\r" $x $i
    sleep 0.1
    
    x=#$x
done
echo

不过记得还有一个dialog工具，于是查了一下资料
dialog的是字符形式的界面  比上一个模拟实现的好的多 虽然还是很丑。。。
不过实现起来同样很简单
for((i=0;i<100;i++))

do 

     sleep 0.1 

     echo $i | dialog --title 'Copy' --gauge 'I am busy!' 10 70 0 

done
参数也比较好理解 title的内容就是对话框的标题 gauge后面的内容是对话框内显示的内容 echo$1是用来显示进度百分比的  
注意这里要根据自己的需求更改 比如我的脚本就是:
echo $((100*(++i-x)/29))  | dialog --title '正在从数据库中' --gauge "下>    载资料 $file.html..." 10 \
70 0

因为我的循环是for((i=x;i<x+29;i++))所以要对百分比的显示做一下换算
这样脚本运行时界面美观一些 ，重要的是可以利用进度条时时监测脚本运行情况。