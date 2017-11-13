DATE=`date +%m/%d/%Y`
TIME=`date +%k:%m:%s`
USERS=`uptime | sed 's/users.*$//' | gawk '{print $NF}'`
LOAD=`uptime | gawk '{print $NF}'`
FREE=`vmstat 1 2 | sed -n '/[0-9]/p' |  sed -n '2p' | gawk '{print $4}'`
IDLE=`vmstat 1 2 | sed -n '/[0-9]/p' |  sed -n '2p' | gawk '{print $15}'`
echo "$DATE-$TIME-$USERS-$LOAD-$FREE-$IDLE" > /var/systemreport/report.csv
echo "<html><body><h2>Report for $DATE</h2>" > /var/systemreport/webreport.html
echo "<table border=\"1\">" >> /var/systemreport/webreport.html
echo "<tr><td>Date</td><td>Time</td><td>Users</td>" >> /var/systemreport/webreport.html
echo "<td>Load</td><td>Free memory</td><td>CPU IDLE</td><tr>" >> /var/systemreport/webreport.html
cat /var/systemreport/report.csv  | awk -F - '{
printf "<tr><td>%s</td><td>%s</td><td>%s</td>",  $1, $2, $3;
printf "<td>%s</td><td>%s</td><td>%s</td>\n</tr>\n",  $4, $5, $6;
}' >> /var/systemreport/webreport.html
echo "</table></body></html>" >> /var/systemreport/webreport.html
mail -a /var/systemreport/webreport.html  "Performance Report $DATE" root  < /dev/null
