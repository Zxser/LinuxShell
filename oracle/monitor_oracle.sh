#!/bin/bash
#Author:daya			#Release 1.0
#Function: check oracle online
declare -a INSTANCE=(PROD EMREP)

[[ -f /home/oracle/.bash_profile ]] && . /home/oracle/.bash_profile || exit 3

function check_listener (){

su - oracle -c "lsnrctl status" >/dev/null 2>&1

if [[ $? -ne 0 ]];then 

	su - oracle -c "lsnrctl start" >/dev/null 2>&1

	[[ $? -ne 0 ]] && echo -e "\E[40;31;5m Your listener is Down!\E[0m"
fi
}
check_listener

function check_oracle (){
	for name in "${INSTANCE[@]}";do
	(su - oracle <<EOF

	sqlplus sys/tiger@${name} as sysdba 
	
	select status from v\$instance;
	quit;

EOF
) >/home/oracle/check_oracle.txt

egrep -q "OPEN" /home/oracle/check_oracle.txt 

[[ $? -ne 0 ]] && echo -e "\E[40;31;5m Oracle ${name} is Down!\E[0m"

done
}
check_oracle




