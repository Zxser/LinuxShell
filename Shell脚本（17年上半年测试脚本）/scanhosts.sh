#!bin/bash
#filename: ip.sh
# 
for ((a=1;a<254;a++))
do
for ((b=1;a<254;b++))
do
for ((c=1;c<254;c++))
do
for ((d=1;d<254;d++))
do
echo $a.$b.$c.$d
echo "ok"
done
done
done
done
