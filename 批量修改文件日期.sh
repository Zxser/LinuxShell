#!/bin/bash
echo -e "Please specify \033[31m Year(with Format:YY):\033[0m"
read YY 
echo -e "Please specify \033[31m Start Month:\033[0m"
read SMM
echo -e "Please specify \033[31m End Month:\033[0m"
read EMM
echo -e "Please specify \033[31m Start Day:\033[0m"
read SDD
echo -e "Please specify \033[31m End Day:\033[0m"
read EDD
echo -e "Please specify \033[31m Start Hour:\033[0m"
read SHH
echo -e "Please specify \033[31m End Hour:\033[0m"
read EHH

for i in `ls -1 ./file`;do
	function NUM() {
		min=$1
		max=$(($2-$min+1))
		num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
		echo $(($num%$max+$min))
		}
	RM=$(NUM $SMM $EMM)
	RnM=`echo $RM | awk '{printf("%02d\n",$0)}'`
	RD=$(NUM $SDD $EDD)
	RnD=`echo $RD | awk '{printf("%02d\n",$0)}'`
	RH=$(NUM $SHH $EHH)
	RnH=`echo $RH | awk '{printf("%02d\n",$0)}'`
	Rm=$(NUM 1 59)
	Rnm=`echo $Rm | awk '{printf("%02d\n",$0)}'`
	Rs=$(NUM 1 59)
	Rns=`echo $Rs | awk '{printf("%02d\n",$0)}'`

	touch -t $YY$RnM$RnD$RnH$Rnm.$Rns ./file/$i
done
