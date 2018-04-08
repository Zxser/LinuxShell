#!/bin/sh
$chain1=datelist.txt
raws=`awk '{print NR}' $chain1|tail -n1`
for i in `seq $raws`
do
slcdate=`awk 'NR=="'$i'" {print $0}' $chain1`
echo $slcdate
slcdate=$(($slcdate+20000000))
echo $slcdate
day=$(( $slcdate % 100 ))
echo $day
yearmonth=`expr $slcdate - $day `
echo $yearmonth
yearmonth=$(( $yearmonth / 100 ))
echo $yearmonth
if (day != 1) & (day != 28) & (day != 29) & (day != 30) & (day != 31)
then
date1=`expr $slcdate - 1`
date2=`expr $slcdate + 1`
echo $date1
echo $date2
fi
done
