#扫描局域网内存活的主机
#!/bin/bash
HLIST=$(cat ~/ipadds.txt)
for IP in $HLIST
do
ping -c 3 -i 0.2 -W 3 $IP &>/dev/null
if [$? -eq 0]; then	
echo "Host $IP is up"
else 
echo "Host $IP is down"
fi
done