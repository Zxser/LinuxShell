#!/bin/bash	
read -p "Enter user password :" PASSWD
for UNAME in 'cat user.txt'
do
    id $UNAME &> /dev/null
    if [ $? -eq 0]
then
    echo "Alreadly exists"
else 
    useradd	$UNAME &> /dev/null
    echo "$PASSWD" | passwd	--stdin	$UNAME &> /dev/null
if [ $? -eq 0 ]
then
    echo "Create success"
else 
    echo "Create failure" 
            fi
        fi 
done
