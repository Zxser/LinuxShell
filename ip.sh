#不带网卡名的方法
ifconfig|grep -Po '(?<=addr:).*(?=  Bcast)'
fconfig|sed -nr 's#.*addr:(.*)  Bcast.*#\1#gp'
ifconfig|awk -F '[ :]+' '!/127.0.0.1/&&/inet\>/{print $4}'
#带网卡名的方法
ifconfig|grep -Po '^eth\d+(:\d+)?|(?<=addr:).*(?=  Bcast)'|xargs -n2
ifconfig|sed -nr '/eth[0-9]/N;s#(eth[0-9]).*addr:(.*)  Bcast.*#\1 \2#gp'
ifconfig|awk -F '[ :]+' 's!~/lo/&&/inet\>/{print s,$4}{s=$1}'


