#!/bin/bash

calc () {
    a=`egrep "GWD-${3}" ${1} | wc -l`
    b=`egrep "GWD-${3}" ${2} | wc -l`
    printf "|%-20s|%10s|%10s|%10s|\n" "Profile=${3}" "${a}" "${b}" $((a - b))
}

printf "|%-20s|%10s|%10s|%10s|\n" "Title" "DataSocket" "WD2 IIS  " "Difference"
printf "|%-20s|%10s|%10s|%10s|\n" "----------" "----------" "----------" "----------"


for i in 333 702 2526
do
    calc $1 "$2" "`awk '{printf("%06d\n",$1)}' <<< ${i}`" &
done

a_num=$((`wc -l ${1} | awk '{print $1}'` - `egrep '^#'  ${1} | wc -l`))
b_num=$((`wc -l ${2} |  awk '/total/{print $1}'` - `egrep '^#'  ${2} | wc -l`))
printf "|%-20s|%10s|%10s|%10s|\n" "Total rows" "${a_num}" "${b_num}" $((a_num - b_num))

read a_uniq b_uniq <<<`cat <(sort -u ${1} | grep -vc '^#') <(sort -u ${2} | grep -vc '^#')`
printf "|%-20s|%10s|%10s|%10s|\n" "Uniq  rows" "$a_uniq" "$b_uniq" $((a_uniq - b_uniq))


# example:
#    ./diff.sh  u_ex16112320.log "u_ex16112320.log.*"
#