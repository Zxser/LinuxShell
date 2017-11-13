#!/bin/bash
read -p "Please Input the user Numbers:" X
for((Y=1;Y<=$X;Y++))
do
	useradd a$Y; echo 1 | passwd a$Y --stdin &> /dev/null
	a=`awk 'BEGIN{printf "%.2f\n",'$Y'/'$X'}'`
	echo $a*100 | bc | cut -d "." -f1 | dialog --title "User Create" --gauge "Starting to create user ..." 6 50 0
done




#!/bin/bash
b=''
i=0
while [ $i -le  100 ]
do
    printf "progress:[%-50s]%d%%\r" $b $i
    sleep 0.1
    i=`expr 2 + $i`        
    b=#$b
done
echo