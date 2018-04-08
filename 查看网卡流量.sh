#!/bin/bash
function Test_arg {
    local arg=$1
    if test -z ${arg}; then
        echo -e "\nUsage : $0 network_interface\n"
        false;exit
    fi
}
function Trap_quit {
    trap 'echo -e "\n\nQuit....\n\a";exit 3' SIGINT;
}
function Get_bytes {
    local Devf="/proc/net/dev"
    RXbyt_bef=`awk -vinterf="$interf" -F':' '$0~interf{print $2}' ${Devf}| awk '{print $1}'`
    TXbyt_bef=`awk -vinterf="$interf" -F':' '$0~interf{print $2}' ${Devf}| awk '{print $9}'`
    sleep ${time}
    RXbyt_aft=`awk -vinterf="$interf" -F':' '$0~interf{print $2}' ${Devf}| awk '{print $1}'`
    TXbyt_aft=`awk -vinterf="$interf" -F':' '$0~interf{print $2}' ${Devf}| awk '{print $9}'`
    clear
}
function Get_speed {
    Byt=$1
    if test ${Byt} -lt 1024 ;then
        speed="${Byt}B/s"
    elif test ${Byt} -gt 1048576 ;then
        speed=$(echo ${Byt} | awk '{print $1/1048576 "MB/s"}')
    else
        speed=$(echo ${Byt} | awk '{print $1/1024 "KB/s"}')
    fi
}

interf=$1
time="1"
Test_arg ${interf}

while :;do
    Trap_quit
    echo -e "${interf}\n \t ${RX_bytes_speed}   ${TX_bytes_speed} "
    Get_bytes
    RX=$[ $(( ${RXbyt_aft} - ${RXbyt_bef} )) / ${time} ]
    TX=$(( $[ ${TXbyt_aft} - ${TXbyt_bef} ] / ${time} ))
    Get_speed ${RX};RX_bytes_speed=${speed}
    Get_speed ${TX};TX_bytes_speed=${speed}
    echo  -e  "\t IN_RX `date +%T` OUT_TX"
done