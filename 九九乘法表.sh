#九九乘法表
#!/bin/bash  
for a in `seq 1 9`
do
echo ""
for b in `seq 1 9`
do
if [ $a -ge $b ]
then
echo -n "$a x $b = $(expr $a \* $b)" \  
fi
done
done
echo ""